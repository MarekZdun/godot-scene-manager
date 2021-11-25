extends "res://addons/scene_manager/main_scene.gd"


func _load_scene() -> void:
	print(level_parameters["player_name"] + " " + str(level_parameters["player_age"]))
	
	
func _unload_scene() -> void:
	pass
