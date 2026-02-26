# Scene Manager(Godot 4.6 version)

A Scene Manager for [Godot Engine](https://godotengine.org/).<br />
Looking for a Godot 3.5 version? [See godot 3.5 branch](https://github.com/MarekZdun/godot-scene-manager/tree/3.5).

## 📄 Features
SceneManager - Manages asynchronous scene loading/unloading with ProxyScene integration.
(c) Pioneer Games
v 1.4

## 📄 Description
SceneManager handles level/scene transitions using background threading for smooth loading.
It works in conjunction with ProxyScene-based scenes, providing a complete scene management
system for games with multiple levels.

## 📄 Requirements:
- Main scene must have a root node named "Main" (accessible at /root/Main)
- The "Main" node must contain a child node named "ActiveSceneContainer" (where scenes will be placed)
- All managed scenes must inherit from `ProxyScene` (abstract base class)
- Scenes must implement `_start(params)` and `_end()` methods (enforced by @abstract)

## 📄 Signals:
- `manager_scene_loaded(scene)` - emitted when scene finishes loading and initialization
- `manager_scene_unloaded(scene_id)` - emitted after scene cleanup and removal
- `manager_scene_load_started(scene_filepath)` - emitted when background loading begins
- `manager_scene_unload_started(scene)` - emitted before current scene is unloaded
- `scene_transitioning(scene_filepath)` - emitted immediately when change_scene() is called
- `main_scene_loaded` - emitted after force_main_scene_to_load completes
- `update_progress(progress)` - emits loading progress (0.0 to 1.0) during background load

## 📄 Usage:
1. Setup main scene structure:
	- Create a main scene (e.g., `main.tscn`)
	- Add a root node named "Main"
	- Add a child node to Main named "ActiveSceneContainer"

2. Create scenes to be managed:
	- Create a new scene (any root type: Node2D, Node3D, Control)
	- Attach a script extending `ProxyScene`
	- Implement required `_start(params)` and `_end()` methods

3. Connect to SceneManager signals (example in a loading screen):
	SceneManager.update_progress.connect(_on_progress_changed)
	SceneManager.manager_scene_loaded.connect(_on_scene_ready)
	SceneManager.manager_scene_unloaded.connect(_on_scene_gone)

4. Change scenes:
	SceneManager.change_scene("res://levels/level_1.tscn", {"difficulty": "easy"})

5. Optional: Force main scene load for testing with F6:
	Enable force_main_scene_to_load in inspector
	Set _main_scene_filepath to your main scene
	When testing any scene with F6 (e.g., a level scene), the following happens:
		- The tested scene is detached from the root
		- The main scene is loaded and becomes the new root
		- The tested scene is reparented to `ActiveSceneContainer` inside the main scene
		- This allows testing individual levels while maintaining the proper scene structure

