extends CanvasLayer
"""
Main scene
Usage:

"""


signal scene_loaded(scene)
signal scene_unloaded(scene)


var scene_name: String


func load_scene(_scene_name):
	scene_name = _scene_name
	
	emit_signal("scene_loaded", self)
	
	
func unload_scene():
	emit_signal("scene_unloaded", self)
