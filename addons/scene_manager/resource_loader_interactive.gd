extends Node


signal resource_loaded(resource)
signal update_progress(progress)


const SIMULATED_DELAY_MS = 32


var loader: Object = null
var wait_frames: int
var time_max: int = 100 # msec


func _ready():
	set_process(false)

	
func _process(delta):
	if not loader:
		set_process(false)
		return
		
	if wait_frames > 0:
		wait_frames -= 1
		return
		
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		
		OS.delay_msec(SIMULATED_DELAY_MS)
		
		if err == ERR_FILE_EOF:
			emit_signal("update_progress", 1)
			var resource = loader.get_resource()
			loader = null
			emit_signal("resource_loaded", resource)
			break
			
		elif err == OK:
			var progress = float(loader.get_stage()) / loader.get_stage_count()
			emit_signal("update_progress", progress)
			
		else:
			print_debug("error during loading")
			loader = null
			break
		
	
func load_scene(filepath) -> void:
	loader = ResourceLoader.load_interactive(filepath)
	set_process(true)
	wait_frames = 1
