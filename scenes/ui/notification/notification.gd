class_name Notification
extends Control

static var instance: Notification
@onready var label: Label = $MarginContainer/Label
static var tween: Tween
var base_position: Vector2

func _ready() -> void:
	instance = self
	modulate.a = 0
	base_position = position


func show_warning(text: String, duration: float = 0.8) -> void:
	position = base_position
	modulate.a = 0
	scale = Vector2(0.9, 0.9)
	if tween:
		tween.stop()
	tween = get_tree().create_tween()
	label.text = text
	modulate = "ff0000"
	visible = true
	tween.tween_property(self, "position", position - Vector2(0, 50), 0.3) \
		.from_current() \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(self, "modulate:a", 1.0, duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(func() -> void:
		self.visible = false
	)
