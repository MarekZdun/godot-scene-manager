extends Node

var current_scene: Node
var loading_screen: Node = preload("res://loading_screen.tscn").instantiate()
var level_one_file_path: String = "res://work/src/levels/level_1.tscn"
var level_two_file_path: String = "res://work/src/levels/level_2.tscn"

@onready var loading_screen_root: Control = loading_screen.get_child(0)
@onready var active_scene_container = $ActiveSceneContainer


func _init():
	add_child(loading_screen)


func _ready():
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.manager_scene_unloaded.connect(_on_scene_gone)
	SceneManager.update_progress.connect(loading_screen._on_progress_changed)

	await get_tree().create_timer(1).timeout

	SceneManager.change_scene(level_one_file_path, {"difficulty": "easy"})

	await get_tree().create_timer(2).timeout

	loading_screen_root.show()
	SceneManager.change_scene(level_two_file_path, {"difficulty": "hard"})

	await get_tree().create_timer(2).timeout

#	loading_screen_root.show()
	SceneManager.change_scene("")


func _on_scene_ready(scene: Node):
	current_scene = scene
	print("scene " + scene.id + " is ready")
	
	await get_tree().create_timer(1).timeout
	loading_screen.reset_progress_bar()
	loading_screen_root.hide()
	
#	get_tree().paused = false
	
func _on_scene_gone(scene_id: String):
	print("scene " + scene_id + " has gone")
