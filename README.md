# Scene Manager(Godot 3.5 version)

A Scene Manager for [Godot Engine](https://godotengine.org/).

## 📄 Features
A manager whose task is to change scenes using a separate thread to load the new scene.

## 📄 Usage
➡️open the SceneManager scene and select the file path to the main scene file for 
	the exported variable main_scene_filepath. This file path will be used to load the main scene 
	during the testing of the scene launched using F6. The main scene will act 
	as a switch between levels. As a requirement, main scene must have Node child named ActiveSceneContainer

➡️in order to know wheter scene finished loading/unloading, connect coresponding signals. Ex:
	
	SceneManager.connect("manager_scene_loaded", self, "_on_scene_ready")
	SceneManager.connect("manager_scene_unloaded", self, "_on_scene_gone")
	
➡️if you want to be informed about state of background loading, connect signal update_progress. Ex:
	
	SceneManager.connect("update_progress", loading_screen, "_on_progress_changed")
	
➡️to change scene, call SceneManager.change_scene(scene_filepath: String, params: Dictionary) Ex:
	
	SceneManager.change_scene("res://src/scenes/main_scenes/scene_1.tscn")
