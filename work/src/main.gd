extends Node


var current_scene: Node = null


func _ready():
	SceneManager.connect("manager_scene_loaded", self, "_on_scene_ready")
	SceneManager.connect("manager_scene_unloaded", self, "_on_scene_gone")
	
	yield(get_tree().create_timer(1), "timeout")
	
	current_scene = SceneManager.change_scene("scene_1")
	
	yield(get_tree().create_timer(2), "timeout")
	
	current_scene = SceneManager.change_scene("scene_2")
	
	yield(get_tree().create_timer(2), "timeout")
	
	current_scene = SceneManager.change_scene("")


func _on_scene_ready(scene: Node):
	print("scene " + scene.scene_name + " is ready")
	
	
func _on_scene_gone(scene_name: String):
	print("scene " + scene_name + " has gone")
