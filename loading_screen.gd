extends CanvasLayer


@onready var progress_bar: ProgressBar = %ProgressBar


func update_progress_bar(progress: float) -> void:
	var new_progress:= progress * 100
	progress_bar.value = lerp(progress_bar.value, new_progress, get_process_delta_time() * 20)
	
	
func reset_progress_bar() -> void:
	progress_bar.value = 0


func _on_progress_changed(progress: float):
	update_progress_bar(progress)


#func update_progress_bar(current: int, total: int) -> void:
#	progress_bar.min_value = 0.0
#	progress_bar.max_value = float(total)
#	progress_bar.value = float(current)
#	progress_bar.update()
#
#
#func _on_progress_changed(current: int, total: int):
#	update_progress_bar(current, total)
