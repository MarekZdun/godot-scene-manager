extends Node


var current_scene: Node = null
var loading_screen: Node = preload("res://work/src/loading_screen.tscn").instance()

onready var loading_screen_root: Control = loading_screen.get_child(0)
onready var active_scene_container = $ActiveSceneContainer


func _init():
	add_child(loading_screen)


func _ready():	
	SceneManager.connect("manager_scene_loaded", self, "_on_scene_ready")
	SceneManager.connect("manager_scene_unloaded", self, "_on_scene_gone")
	
	SceneManager.get_node("ResourceLoaderInteractive").connect("update_progress", loading_screen, "_on_progress_changed")
	SceneManager.get_node("ResourceLoaderMultithread").connect("update_progress", loading_screen, "_on_progress_changed")

	yield(get_tree().create_timer(1), "timeout")

	SceneManager.change_scene("res://work/src/scenes/main_scenes/scene_1.tscn")

	yield(get_tree().create_timer(2), "timeout")

	loading_screen_root.show()
	SceneManager.change_scene("res://work/src/scenes/main_scenes/scene_2.tscn")

	yield(get_tree().create_timer(2), "timeout")

#	loading_screen_root.show()
	SceneManager.change_scene("")


func _on_scene_ready(scene: Node):
	current_scene = scene
	print("scene " + scene.id + " is ready")
	
	yield(get_tree().create_timer(1), "timeout")
	loading_screen.reset_progress_bar()
	loading_screen_root.hide()
	
#	get_tree().paused = false
	
func _on_scene_gone(scene_id: String):
	print("scene " + scene_id + " has gone")
