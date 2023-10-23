extends Node
"""
Manager whose purpose is to control switching between scene levels
(c) Pioneer Games
v 1.2

Usage:
-open the SceneManager scene and select the file path to the main scene file for 
	the exported variable main_scene_filepath. This file path will be used to load the main scene 
	during the testing of the scene launched using F6. The main scene will act 
	as a switch between levels. As a requiment, main scene must have Node child named ActiveSceneContainer

-in order to know wheter scene finished loading/unloading, connect coresponding signals. Ex:
	
	SceneManager.connect("manager_scene_loaded", Callable(self, "_on_scene_ready"))
	SceneManager.connect("manager_scene_unloaded", Callable(self, "_on_scene_gone"))
	
-if you want to be informed about state of background loading, connect signal update_progress. Ex:
	
	SceneManager.connect("update_progress", Callable(loading_screen, "_on_progress_changed"))
	
-to change scene, call SceneManager.change_scene_to_file(scene_filepath: String, params: Dictionary) Ex:
	
	SceneManager.change_scene_to_file("res://src/scenes/main_scenes/scene_1.tscn")
"""


signal manager_scene_loaded(scene)
signal manager_scene_unloaded(scene_id)
signal scene_transitioning(scene_filepath)
signal main_scene_loaded()

@export var main_scene_filepath: String = "res://src/main.tscn" # (String, FILE)

var current_scene: Node = null
var utils: Utils = Utils.new()
var next_scene_id_cashe: String
var scene_parameters_cache: Dictionary

@onready var main: Node = get_node_or_null("/root/Main")
@onready var active_scene_container: Node = get_node_or_null("/root/Main/ActiveSceneContainer")
@onready var resource_loader_interactive: Node = get_node("ResourceLoaderInteractive")
@onready var resource_loader_multithread: Node = get_node("ResourceLoaderMultithread")


func _ready():
	if not main:
		call_deferred("_force_main_scene_load")
		await self.main_scene_loaded
	
	if active_scene_container.get_child_count() > 0:
		current_scene = active_scene_container.get_child(0) 


func change_scene_to_file(scene_filepath: String, params: Dictionary = {}) -> void:
	emit_signal("scene_transitioning", scene_filepath)
	
	if current_scene:
		current_scene.connect("scene_unloaded", Callable(self, "_on_scene_unloaded").bind(), CONNECT_ONE_SHOT)
		current_scene.unload_scene()
		if current_scene.is_inside_tree():
			await current_scene.tree_exited
		current_scene = null
	
	if not scene_filepath.is_empty() and _is_scene_filepath_valid(scene_filepath):
		next_scene_id_cashe = scene_filepath
		scene_parameters_cache = params
		
		if OS.has_feature("HTML5"):
			resource_loader_interactive.connect("resource_loaded", Callable(self, "_on_resource_loaded").bind(), CONNECT_ONE_SHOT)
			resource_loader_interactive.load_scene(scene_filepath)
		else:
			resource_loader_multithread.connect("resource_loaded", Callable(self, "_on_resource_loaded").bind(), CONNECT_ONE_SHOT)
			resource_loader_multithread.load_scene(scene_filepath)
	else:
		print_debug("Scene file not found")
	
	
func _set_new_scene(resource: PackedScene) -> void:
	var next_scene = resource.instantiate()
	if next_scene:
		active_scene_container.add_child(next_scene)
		
		next_scene.connect("scene_loaded", Callable(self, "_on_scene_loaded").bind(), CONNECT_ONE_SHOT)
		next_scene.load_scene(next_scene_id_cashe, scene_parameters_cache)
		
		current_scene = next_scene
		
		
func _is_scene_filepath_valid(filepath: String) -> bool:
	var valid
	var file = File.new()
	
	if file.file_exists(filepath):
		valid = true
	else:
		valid = false
		
	return valid
	
	
func _force_main_scene_load():
	var played_scene = get_tree().current_scene
	var root = get_node("/root")
	main = load(main_scene_filepath).instantiate()
	root.remove_child(played_scene)
	root.add_child(main)
	
	active_scene_container = main.get_node("ActiveSceneContainer")
	if active_scene_container.get_child_count() > 0:
		var scene_in_container = main.active_scene_container.get_child(0)
		if scene_in_container:
			scene_in_container.queue_free()
			if scene_in_container.is_inside_tree():
				await scene_in_container.tree_exited
		
	active_scene_container.add_child(played_scene)
	
	if played_scene.has_method("start"):
		played_scene.start({})
	
	played_scene.owner = main
	
	emit_signal("main_scene_loaded")
	
	
func _on_resource_loaded(resource):
	_set_new_scene(resource)
	
	
func _on_scene_loaded(scene):
	emit_signal("manager_scene_loaded", scene)
	
	
func _on_scene_unloaded(scene):
	var scene_id = scene.id
	scene.queue_free()
	emit_signal("manager_scene_unloaded", scene_id)


class Utils extends Resource:
	const SCENETYPE: Array = ['tscn.converted.scn', 'scn', 'tscn']
	
	func load_scene_instance(p_name: String, p_dir: String) -> Node:
	    var file = File.new()
	    var filepath = ''
	    var scene = null

	    for ext in SCENETYPE:
	        filepath = '%s/%s.%s' % [p_dir, p_name, ext]

	        if file.file_exists(filepath):
	            scene = load(filepath).instantiate()
	            break

	    return scene
		
		
	func get_scene_path(p_name: String, p_dir: String) -> Object:
		var file = File.new()
		var filepath = ''
		var exists = false

		for ext in SCENETYPE:
			filepath = '%s/%s.%s' % [p_dir, p_name, ext]

			if file.file_exists(filepath):
				exists = true
				break
		
		if not exists:
			filepath = ''
				
		return filepath
