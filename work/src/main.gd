extends Node


var current_scene: Node = null
var loading_screen: Node = preload("res://work/src/loading_screen.tscn").instantiate()

@onready var loading_screen_root: Control = loading_screen.get_child(0)
@onready var active_scene_container = $ActiveSceneContainer


func _init():
	add_child(loading_screen)


func _ready():	
	SceneManager.connect("manager_scene_loaded", Callable(self, "_on_scene_ready"))
	SceneManager.connect("manager_scene_unloaded", Callable(self, "_on_scene_gone"))
	
	SceneManager.get_node("ResourceLoaderInteractive").connect("update_progress", Callable(loading_screen, "_on_progress_changed"))
	SceneManager.get_node("ResourceLoaderMultithread").connect("update_progress", Callable(loading_screen, "_on_progress_changed"))

	await get_tree().create_timer(1).timeout

	SceneManager.change_scene_to_file("res://work/src/scenes/main_scenes/scene_1.tscn")

	await get_tree().create_timer(2).timeout

	loading_screen_root.show()
	SceneManager.change_scene_to_file("res://work/src/scenes/main_scenes/scene_2.tscn")

	await get_tree().create_timer(2).timeout

#	loading_screen_root.show()
	SceneManager.change_scene_to_file("")


func _on_scene_ready(scene: Node):
	current_scene = scene
	print("scene " + scene.id + " is ready")
	
	await get_tree().create_timer(1).timeout
	loading_screen.reset_progress_bar()
	loading_screen_root.hide()
	
#	get_tree().paused = false
	
func _on_scene_gone(scene_id: String):
	print("scene " + scene_id + " has gone")
