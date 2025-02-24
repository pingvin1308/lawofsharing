extends Button


func _pressed() -> void:
	EventBus.terminal_day_ended.emit()
