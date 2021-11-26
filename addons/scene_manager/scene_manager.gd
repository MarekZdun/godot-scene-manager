extends Node
"""
Manager whose purpose is to control scenes
(c) Pioneer Games
v 1.0
Usage:

"""


signal manager_scene_loaded(scene)
signal manager_scene_unloaded(scene_name)


export(String, DIR) var main_scenes_dir: String = "res://src/scenes/main_scenes/"
var current_scene: Node = null
var utils: Utils = Utils.new()
var next_scene_name_cashe: String
var loader: Object
var wait_frames: int
var time_max: int = 100 # msec
var level_parameters_cache: Dictionary


func _process(delta):
	if not loader:
		set_process(false)
		return
		
	if wait_frames > 0:
		wait_frames -= 1
		return
		
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
			
		elif err == OK:
			update_progress()
			
		else:
			print_debug("error during loading")
			loader = null
			break
			
			
func update_progress() -> void:
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	emit_signal("update_progress", progress)


func change_scene(scene_name: String) -> void:
	next_scene_name_cashe = scene_name
	loader = utils.get_loader(scene_name, main_scenes_dir)
	if not loader:
		print_debug("loader not found")
	else:
		set_process(true)
		wait_frames = 1
	
	if current_scene:
		current_scene.connect("scene_unloaded", self, "_on_scene_unloaded")
		current_scene.unload_scene()
	
	
func set_new_scene(scene_resource: Resource) -> void:
	var next_scene = scene_resource.instance()
	if next_scene:
		add_child(next_scene)

		send_level_parameters_to(next_scene)
		
		next_scene.connect("scene_loaded", self, "_on_scene_loaded")
		next_scene.load_scene(next_scene_name_cashe)
		
		current_scene = next_scene
	
	
func receive_level_parameters_from(scene: Node) -> void:
	level_parameters_cache = scene.get_level_parameters()
	
	
func send_level_parameters_to(scene: Node) -> void:
	if not level_parameters_cache.empty():
		scene.set_level_parameters(level_parameters_cache)
	
	
func _on_scene_loaded(scene):
	emit_signal("manager_scene_loaded", scene)
	
	
func _on_scene_unloaded(scene):
	var scene_name = scene.scene_name
	receive_level_parameters_from(scene)
	scene.queue_free()
	emit_signal("manager_scene_unloaded", scene_name)


class Utils extends Resource:
	const SCENETYPE: Array = ['tscn.converted.scn', 'scn', 'tscn']
	
	func load_scene_instance(name: String, dir: String) -> Node:
	    var file = File.new()
	    var path = ''
	    var scene = null

	    for ext in SCENETYPE:
	        path = '%s/%s.%s' % [dir, name, ext]

	        if file.file_exists(path):
	            scene = load(path).instance()
	            break

	    return scene
		
		
	func get_loader(name: String, dir: String) -> Object:
		var file = File.new()
		var path = ''
		var loader = null

		for ext in SCENETYPE:
			path = '%s/%s.%s' % [dir, name, ext]

			if file.file_exists(path):
				loader = ResourceLoader.load_interactive(path)
				break
				
		return loader
