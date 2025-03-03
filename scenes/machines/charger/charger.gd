class_name Charger
extends MachineBase

signal electricity_changed()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $ChargerIcon/Label
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var charger_icon: Control = $ChargerIcon

var room_name: String
var is_in_range: bool = false
var source: int:
	get(): return data.source_value
	set(value):
		data.source_value = value
		EventBus.room_recourse_changed.emit(data.room_index, Data.ResourceType.ELECTRICITY, data.source_value)
		electricity_changed.emit()
		label.text = str(data.source_value)


func _on_interactable_activated() -> void:
	var interactor := interactable_component.interactor;
	if interactor.resource_box != null and interactor.resource_box.resource_type == Data.ResourceType.ELECTRICITY:
		control_menu.action_name = "fill"
		control_menu.connect_signals(_on_fill_pressed)
	else:
		control_menu.action_name = ""
		control_menu.disconnect_signals(_on_fill_pressed)

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


func _on_fill_pressed() -> void:
	if is_in_range:
		var player := interactable_component.interactor
		on_fill(player)


func on_fill(player: Player) -> void:
	if player.resource_box == null: return
	var electricity_amount := player.resource_box.value
	source += electricity_amount
	player.empty_resource_box()


func enable_hud() -> void:
	charger_icon.visible = true


func disable_hud() -> void:
	charger_icon.visible = false
