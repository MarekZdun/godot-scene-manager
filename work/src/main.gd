extends Node


var current_scene: Node = null
onready var loading_screen: Node = $LoadingScreen
onready var loading_screen_root: Control = loading_screen.get_child(0)


func _ready():
	SceneManager.connect("manager_scene_loaded", self, "_on_scene_ready")
	SceneManager.connect("manager_scene_unloaded", self, "_on_scene_gone")
	
	SceneManager.connect("update_progress", loading_screen, "_on_progress_changed")
	
	yield(get_tree().create_timer(1), "timeout")
	
	SceneManager.change_scene("scene_1")
	
	yield(get_tree().create_timer(2), "timeout")
	
	loading_screen_root.show()
	SceneManager.change_scene("scene_2")
	
	yield(get_tree().create_timer(2), "timeout")
	
	loading_screen_root.show()
	SceneManager.change_scene("")


func _on_scene_ready(scene: Node):
	current_scene = scene
	print("scene " + scene.scene_name + " is ready")
	yield(get_tree().create_timer(1), "timeout")
	loading_screen_root.hide()
	
	
func _on_scene_gone(scene_name: String):
	print("scene " + scene_name + " has gone")
