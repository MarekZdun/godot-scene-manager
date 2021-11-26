extends CanvasLayer
"""
Main scene

Usage:
-right click on main_scene.tscn file in File System and choose New Inherited Scene

-right click on MainScene node (top one) and choose Extend Script to add additional funcionality to your scene

-add functionality in _load_scene() and _unload_scene() in inherited scene

-if you want to send data from old scene to new one, set level_parameters dictionary in inherited scene of old scene
"""


signal scene_loaded(scene)
signal scene_unloaded(scene)


var scene_name: String
var level_parameters: Dictionary setget set_level_parameters, get_level_parameters


func set_level_parameters(_level_parameters: Dictionary) -> void:
	level_parameters = _level_parameters
	
	
func get_level_parameters() -> Dictionary:
	return level_parameters


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
