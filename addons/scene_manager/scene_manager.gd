extends Node
"""
SceneManager - Manages asynchronous scene loading/unloading with ProxyScene integration.
(c) Pioneer Games
v 1.4

DESCRIPTION:
SceneManager handles level/scene transitions using background threading for smooth loading.
It works in conjunction with ProxyScene-based scenes, providing a complete scene management
system for games with multiple levels.

REQUIREMENTS:
- Main scene must have a root node named "Main" (accessible at /root/Main)
- The "Main" node must contain a child node named "ActiveSceneContainer" (where scenes will be placed)
- All managed scenes must inherit from `ProxyScene` (abstract base class)
- Scenes must implement `_start(params)` and `_end()` methods (enforced by @abstract)

SIGNALS - Monitor scene lifecycle:
- `manager_scene_loaded(scene)` - emitted when scene finishes loading and initialization
- `manager_scene_unloaded(scene_id)` - emitted after scene cleanup and removal
- `manager_scene_load_started(scene_filepath)` - emitted when background loading begins
- `manager_scene_unload_started(scene)` - emitted before current scene is unloaded
- `scene_transitioning(scene_filepath)` - emitted immediately when change_scene() is called
- `main_scene_loaded` - emitted after force_main_scene_to_load completes
- `update_progress(progress)` - emits loading progress (0.0 to 1.0) during background load

USAGE:
1. Setup main scene structure:
	- Create a main scene (e.g., `main.tscn`)
	- Add a root node named "Main"
	- Add a child node to Main named "ActiveSceneContainer"

2. Create scenes to be managed:
	- Create a new scene (any root type: Node2D, Node3D, Control)
	- Attach a script extending `ProxyScene`
	- Implement required `_start(params)` and `_end()` methods

3. Connect to SceneManager signals (example in a loading screen):
	SceneManager.update_progress.connect(_on_progress_changed)
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.manager_scene_unloaded.connect(_on_scene_gone)

4. Change scenes:
	SceneManager.change_scene("res://levels/level_1.tscn", {"difficulty": "easy"})

5. Optional: Force main scene load for testing with F6:
	Enable force_main_scene_to_load in inspector
	Set _main_scene_filepath to your main scene
	When testing any scene with F6 (e.g., a level scene), the following happens:
		- The tested scene is detached from the root
		- The main scene is loaded and becomes the new root
		- The tested scene is reparented to `ActiveSceneContainer` inside the main scene
		- This allows testing individual levels while maintaining the proper scene structure
"""


signal manager_scene_loaded(scene)
signal manager_scene_unloaded(scene_id)
signal manager_scene_load_started(scene_filepath)
signal manager_scene_unload_started(scene)
signal scene_transitioning(scene_filepath)
signal main_scene_loaded
signal update_progress(progress)

const SIMULATED_DELAY_MS = 32
const OK_LOADING_STATUSES = [ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED]

@export var force_main_scene_to_load: bool = false
@export_file var _main_scene_filepath: String = "res://src/main.tscn"

var current_scene: Node = null
var loading_scene: bool = false:
	set(value):
		loading_scene = value
		set_process(loading_scene)
var loading_scene_filepath: String
var progress: Array
var _loading_scene_params_cache: Dictionary

@onready var main: Node = get_node_or_null("/root/Main")
@onready var active_scene_container: Node = get_node_or_null("/root/Main/ActiveSceneContainer")


func _ready():
	loading_scene = false
	
	if force_main_scene_to_load and not main:
		_force_main_scene_load.call_deferred()
		await main_scene_loaded
	
	if active_scene_container == null:
		push_warning("ActiveSceneContainer not found! Scene system may not work correctly.")
		return
	
	if active_scene_container.get_child_count() > 0:
		current_scene = active_scene_container.get_child(0)
	else:
		current_scene = null
		
		
func _process(delta):
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(loading_scene_filepath, progress)
	assert(OK_LOADING_STATUSES.has(status), "There was an error while loading %s." % loading_scene_filepath)
	
	update_progress.emit(progress[0])
	OS.delay_msec(SIMULATED_DELAY_MS)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		update_progress.emit(1.0)
		_set_new_scene(ResourceLoader.load_threaded_get(loading_scene_filepath))
		loading_scene = false


func change_scene(scene_filepath: String, scene_params: Dictionary = {}) -> void:
	scene_transitioning.emit(scene_filepath)
	
	if current_scene:
		manager_scene_unload_started.emit(current_scene)
		current_scene.scene_unloaded.connect(_on_scene_unloaded, CONNECT_ONE_SHOT)
		current_scene.unload_scene()
		if current_scene.is_inside_tree():
			await current_scene.tree_exited
		current_scene = null
	
	if _is_filepath_valid(scene_filepath):
		manager_scene_load_started.emit(scene_filepath)
		loading_scene_filepath = scene_filepath
		_loading_scene_params_cache = scene_params
		
		ResourceLoader.load_threaded_request(scene_filepath, "PackedScene")
		loading_scene = true
	else:
		print_debug("Scene file not found")
	
	
func _set_new_scene(resource: PackedScene) -> void:
	var new_scene := resource.instantiate()
	if new_scene:
		active_scene_container.add_child(new_scene)
		
		new_scene.scene_loaded.connect(_on_scene_loaded, CONNECT_ONE_SHOT)
		new_scene.load_scene(_loading_scene_params_cache)
		
		current_scene = new_scene
		
		
func _is_filepath_valid(filepath: String) -> bool:
	if not filepath.is_empty() and FileAccess.file_exists(filepath):
		return true
	return false
	
	
func _force_main_scene_load() -> void:
	var played_scene := get_tree().current_scene
	var root := get_node("/root")
	
	if not FileAccess.file_exists(_main_scene_filepath):
			push_error("Main scene file not found: ", _main_scene_filepath)
			return
	
	var main_scene_resource := load(_main_scene_filepath)
	if main_scene_resource == null:
		push_error("Failed to load main scene: ", _main_scene_filepath)
		return
		
	main = main_scene_resource.instantiate()
	root.remove_child(played_scene)
	root.add_child(main)

	active_scene_container = main.get_node_or_null("ActiveSceneContainer")
	if active_scene_container == null:
		push_error("ActiveSceneContainer not found in main scene!")
		active_scene_container = Node.new()
		active_scene_container.name = "ActiveSceneContainer"
		main.add_child(active_scene_container)
	
	if active_scene_container.get_child_count() > 0:
		var scene_in_container: Node = main.active_scene_container.get_child(0)
		if scene_in_container:
			scene_in_container.queue_free()
			if scene_in_container.is_inside_tree():
				await scene_in_container.tree_exited
		
	active_scene_container.add_child(played_scene)
	
	if played_scene.has_method("start"):
		played_scene.start({})
	
	played_scene.owner = main
	
	main_scene_loaded.emit()
	
	
func _on_scene_loaded(scene: Node):
	manager_scene_loaded.emit(scene)
	
	
func _on_scene_unloaded(scene: Node):
	var scene_id: String = scene.id
	scene.queue_free()
	manager_scene_unloaded.emit(scene_id)
