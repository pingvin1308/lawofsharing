class_name WaterCooler
extends MachineBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var label: Label = $WaterIcon/Label
@onready var water_icon: Control = $WaterIcon


var is_in_range: bool = false
var source: int:
	get(): return data.source_value
	set(value):
		data.source_value = value
		label.text = str(data.source_value)
		EventBus.room_recourse_changed.emit(data.room_index, Data.ResourceType.WATER, data.source_value)


func _ready() -> void:
	control_menu.action_pressed.connect(_on_drink_pressed)


func set_source(value: int) -> void:
	source = value


func _on_interactable_activated() -> void:
	var interactor := interactable_component.interactor;
	if interactor.resource_box != null and interactor.resource_box.resource_type == Data.ResourceType.WATER:
		control_menu.action_name = "fill"
		control_menu.disconnect_signals(_on_drink_pressed)
		control_menu.connect_signals(_on_fill_pressed)
	else:
		control_menu.action_name = "drink"
		control_menu.disconnect_signals(_on_fill_pressed)
		control_menu.connect_signals(_on_drink_pressed)

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


func _on_drink_pressed() -> void:
	if is_in_range:
		var player := interactable_component.interactor
		on_drink(player)


func _on_fill_pressed() -> void:
	if is_in_range:
		var player := interactable_component.interactor
		on_fill(player)


func on_fill(player: Player) -> void:
	if player.resource_box == null: return
	var water_amount := player.resource_box.value
	source += water_amount
	player.empty_resource_box()


func on_drink(player: Player) -> void:
	var current_water: int = player.water
	var max_water := Data.PlayerData.MAX_WATER
	var needed_water := max_water - current_water
	if (needed_water <= 0):
		return

	var value := needed_water if source - needed_water > 0 else source
	source -= value
	player.drink(value)


func enable_hud() -> void:
	water_icon.visible = true


func disable_hud() -> void:
	water_icon.visible = false
