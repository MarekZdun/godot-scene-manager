extends ProxyScene

func _start(params) -> void:
	print("[LOG] start: ", scene_file_path, " params: ", params)
	
	
func _end() -> void:
	print("[LOG] end: ", scene_file_path)
