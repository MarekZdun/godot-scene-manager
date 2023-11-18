class_name ProxyScene
extends CanvasLayer
"""
Proxy scene

Usage:
-right click on proxy_scene.tscn file in File System and choose New Inherited Scene

-right click on ProxyScene node (top one) and choose Extend Script to add additional funcionality to your scene

-add functionality to _start() and _end() functions in inherited scene. These functions will be called 
	when scene is loaded/unloaded respectively.
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
	
	
func _start(params: Dictionary) -> void:
	pass	#can override this
	
	
func _end() -> void:
	pass	#can override this
