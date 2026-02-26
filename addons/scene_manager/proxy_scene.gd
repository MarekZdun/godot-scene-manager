@abstract class_name ProxyScene 
extends Node
"""
ProxyScene - abstract base class for scenes used by SceneManager.

DESCRIPTION:
ProxyScene is a base class that SceneManager uses to manage various game scenes.
Every scene that needs to be loaded/unloaded by SceneManager must inherit from
this class. This includes:
- Game levels
- Character selection screens
- Cutscenes
- Any other scene type that needs dynamic loading

The class provides the essential methods and signals that SceneManager relies on
to control scene lifecycle.

USAGE:
1. Create a new scene
2. Add a root node of your choice (e.g., Node2D, Node3D, Control)
3. Attach a new script to the root node
4. Make the script extend `ProxyScene`
"""


signal scene_loaded(scene)
signal scene_unloaded(scene)

@export var id: String = ""


func load_scene(params: Dictionary) -> void:
	if id.is_empty():
		id = scene_file_path
	
	_start(params)
	scene_loaded.emit(self)
	
	
func unload_scene() -> void:
	_end()
	scene_unloaded.emit(self)
	
	
@abstract func _start(params: Dictionary) -> void
	
	
@abstract func _end() -> void
