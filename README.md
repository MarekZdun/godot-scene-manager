# Scene Manager(Godot 4.1 version)

A Scene Manager for [Godot Engine](https://godotengine.org/).<br />
Looking for a Godot 3.5 version? [See godot 3.5 branch](https://github.com/MarekZdun/godot-scene-manager/tree/3.5).

## 📄 Features
A manager whose task is to change scenes using a separate thread to load the new scene.

## 📄 Usage
➡️ open the SceneManager scene and select the file path to the main scene file for 
	the exported variable _main_scene_filepath. This file path will be used to load the main scene 
	during the testing of the scene launched using F6. The main scene will act 
	as a switch between levels. As a requiment, main scene must have Node child named ActiveSceneContainer

➡️ in order to know wheter scene finished loading/unloading, connect coresponding signals. Ex:
	
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.manager_scene_unloaded.connect(_on_scene_gone)
	
➡️ if you want to be informed about state of background loading, connect signal update_progress. Ex:
	
	SceneManager.update_progress.connect(loading_screen._on_progress_changed)
	
➡️ to change scene, call change_scene(scene_filepath: String, scene_id: String = "", scene_params: Dictionary = {}) Ex:
	
	SceneManager.change_scene("res://work/src/scenes/main_scenes/scene_1.tscn", "my_scene_1", {"difficulty": "easy"})
