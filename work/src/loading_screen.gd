extends CanvasLayer


@onready var progress_bar = get_node("Root/CenterContainer/VBoxContainer/ProgressBar")


func update_progress_bar(progress: float) -> void:
	progress_bar.value = progress * 100
	progress_bar.update()
	
	
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
