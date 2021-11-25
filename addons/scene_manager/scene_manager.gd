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
var utils = Utils.new()


func change_scene(scene_name: String) -> Node:
	if current_scene:
		current_scene.connect("scene_unloaded", self, "_on_scene_unloaded")
		current_scene.unload_scene()
		
	var next_scene = utils.load_scene_instance(scene_name, main_scenes_dir)
	if next_scene:
		next_scene.connect("scene_loaded", self, "_on_scene_loaded")
		add_child(next_scene)
		
		next_scene.load_scene(scene_name)
		current_scene = next_scene
	
	return next_scene
	
	
func _on_scene_loaded(scene):
	emit_signal("manager_scene_loaded", scene)
	
	
func _on_scene_unloaded(scene):
	var scene_name = scene.scene_name
	scene.queue_free()
	emit_signal("manager_scene_unloaded", scene_name)


class Utils extends Resource:
	const SCENETYPE: Array = ['tscn.converted.scn', 'scn', 'tscn']
	
	var auto_id: int = 0
	
	func load_scene_instance(name: String, dir: String) -> Control:
	    var file = File.new()
	    var path = ''
	    var scene = null

	    for ext in SCENETYPE:
	        path = '%s/%s.%s' % [dir, name, ext]

	        if file.file_exists(path):
	            scene = load(path).instance()
	            break

	    return scene
