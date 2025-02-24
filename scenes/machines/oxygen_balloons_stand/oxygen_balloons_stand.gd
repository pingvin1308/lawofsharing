class_name OxygenBalloons
extends MachineBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $OxygenIcon/Label
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var control_menu: ControlMenu = $ControlMenu

var room_name: String
var is_in_range: bool = false
var source: int:
	get(): return data.source_value
	set(value):
		data.source_value = value
		label.text = str(data.source_value)
		EventBus.room_recource_changed.emit(data.room_index, Data.ResourceType.OXYGEN, data.source_value)


func _ready() -> void:
	control_menu.modulate.a = 0


func _on_interactable_activated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)


func _on_interactable_deactivated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)
