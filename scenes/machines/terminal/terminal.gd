class_name Terminal
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var control_menu: ControlMenu = $ControlMenu

var is_in_range: bool = false


func _ready() -> void:
	control_menu.action_pressed.connect(_on_open)


func _on_interactable_activated() -> void:
	control_menu.action_name = "open"
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()


func _on_interactable_deactivated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()


func _on_open() -> void:
	EventBus.terminal_menu_opened.emit()
