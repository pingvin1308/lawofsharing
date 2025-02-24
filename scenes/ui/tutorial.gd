class_name TutorialMenu

extends Control

signal finished()


var index: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_paused: bool = false

func _ready() -> void:
	animation_player.play("test")


func next() -> void:
	index += 1
	animation_player.play()


func pause() -> void:
	is_paused = true
	animation_player.pause()


func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	var is_left_click: bool = (mouse_event.button_index == MOUSE_BUTTON_LEFT
		and mouse_event.pressed)

	if is_paused and is_left_click:
		next()


func _on_animation_finished(_anim_name: StringName) -> void:
	finished.emit()
	queue_free()
