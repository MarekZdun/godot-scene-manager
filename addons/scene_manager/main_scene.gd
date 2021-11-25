extends CanvasLayer
"""
Main scene
Usage:

"""


signal scene_loaded(scene)
signal scene_unloaded(scene)


var scene_name: String
var level_parameters: Dictionary


func load_scene(_scene_name: String) -> void:
	scene_name = _scene_name
	
	_load_scene()
	emit_signal("scene_loaded", self)
	
	
func unload_scene() -> void:
	
	_unload_scene()
	emit_signal("scene_unloaded", self)
	
	
func _load_scene() -> void:
	assert(false, "Override activate in subtypes")
	
	
func _unload_scene() -> void:
	assert(false, "Override activate in subtypes")
	
	
func load_level_parameters(_level_parameters: Dictionary) -> void:
	level_parameters = _level_parameters
