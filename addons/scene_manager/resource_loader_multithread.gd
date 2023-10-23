extends Node


signal resource_loaded(resource)
signal update_progress(progress)


const SIMULATED_DELAY_MS = 32 


var thread: Thread = null


func _ready():
	thread = Thread.new()
	
	
func load_scene(filepath) -> void:
	var state = thread.start(Callable(self, "_thread_load").bind(filepath))
	if state != OK:
		print_debug("Error while starting thread: " + str(state))
		
		
func _thread_load(filepath) -> void:
	var loader = ResourceLoader.load_threaded_request(filepath)
	var resource = null
	
	while true:
		var progress = float(loader.get_stage()) / loader.get_stage_count()
		emit_signal("update_progress", progress)
		
		OS.delay_msec(SIMULATED_DELAY_MS)
		
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			resource = loader.get_resource()
			loader = null
			break
			
		elif err != OK:
			print_debug("error during loading")
			break
		
	call_deferred("_thread_done", resource)
	
	
func _thread_done(resource):
	assert(resource)
	thread.wait_to_finish()
	
	emit_signal("update_progress", 1.0)
	emit_signal("resource_loaded", resource)
