extends Node
"""
A manager whose task is to change scenes using a separate thread to load the new scene.
(c) Pioneer Games
v 1.2

Usage:
-open the SceneManager scene and select the file path to the main scene file for 
	the exported variable _main_scene_filepath. This file path will be used to load the main scene 
	during the testing of the scene launched using F6. The main scene will act 
	as a switch between levels. As a requiment, main scene must have Node child named ActiveSceneContainer

-in order to know wheter scene finished loading/unloading, connect coresponding signals. Ex:
	
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.manager_scene_unloaded.connect(_on_scene_gone)
	
-if you want to be informed about state of background loading, connect signal update_progress. Ex:
	
	SceneManager.update_progress.connect(loading_screen._on_progress_changed)
	
-to change scene, call change_scene(scene_filepath: String, scene_params: Dictionary = {}) Ex:
	
	SceneManager.change_scene("res://work/src/scenes/main_scenes/scene_1.tscn", {"difficulty": "easy"})
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
	
	if not main:
		_force_main_scene_load.call_deferred()
		await main_scene_loaded
	
	if active_scene_container.get_child_count() > 0:
		current_scene = active_scene_container.get_child(0)
		
		
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
	main = load(_main_scene_filepath).instantiate()
	root.remove_child(played_scene)
	root.add_child(main)
	
	active_scene_container = main.get_node("ActiveSceneContainer")
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
