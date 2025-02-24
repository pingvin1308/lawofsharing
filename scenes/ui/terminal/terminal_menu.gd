class_name TerminalMenu
extends Control

@export var close: Button
@onready var color_rect: ColorRect = $ColorRect
@onready var player_room: PlayerRoom = %PlayerRoom
@onready var rooms_container: RoomsContainer = %RoomsContainer


func initialize() -> void:
	player_room.initialize()
	rooms_container.initialize()

	EventBus.terminal_menu_opened.connect(_on_open)
	color_rect.gui_input.connect(on_click)
	close.pressed.connect(on_close_pressed)


func _on_open() -> void:
	visible = true


func on_close_pressed() -> void:
	visible = false
	EventBus.terminal_menu_closed.emit()


func on_click(event: InputEventMouseButton) -> void:
	var is_left_click: bool = (event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed)

	if is_left_click:
		on_close_pressed()
