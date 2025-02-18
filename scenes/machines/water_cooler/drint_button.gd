extends Button

signal drink()

func _pressed() -> void:
	drink.emit()
