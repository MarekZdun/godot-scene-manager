@tool
extends EditorPlugin

const SCENE_MANAGER_FILEPATH = "res://addons/scene_manager/scene_manager.tscn"
const SCENE_MANAGER_AUTLOAD_NAME = "SceneManager"


func _enable_plugin():
	add_autoload_singleton(SCENE_MANAGER_AUTLOAD_NAME, SCENE_MANAGER_FILEPATH)


func _disable_plugin():
	remove_autoload_singleton(SCENE_MANAGER_AUTLOAD_NAME)
