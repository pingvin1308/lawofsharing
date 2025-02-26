class_name FoodStand
extends MachineBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $FoodIcon/Label
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var food_icon: Control = $FoodIcon

var room_name: String
var is_in_range: bool = false

var source: int:
	get(): return data.source_value
	set(value):
		data.source_value = value
		EventBus.room_recource_changed.emit(data.room_index, Data.ResourceType.FOOD, data.source_value)
		label.text = str(data.source_value)


func _ready() -> void:
	control_menu.action_pressed.connect(_on_eat_pressed)


func set_source(value: int) -> void:
	source = value


func _on_interactable_activated() -> void:
	var interactor := interactable_component.interactor;
	if interactor.resource_box != null and interactor.resource_box.resource_type == Data.ResourceType.FOOD:
		control_menu.action_name = "fill"
		control_menu.connect_signals(_on_fill_pressed)
		control_menu.disconnect_signals(_on_eat_pressed)

	else:
		control_menu.action_name = "eat"
		control_menu.connect_signals(_on_fill_pressed)
		control_menu.disconnect_signals(_on_eat_pressed)

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


func _on_eat_pressed() -> void:
	if is_in_range:
		var player := interactable_component.interactor
		on_eat(player)


func on_eat(player: Player) -> void:
	var current_food := player.food
	var max_food := Data.PlayerData.MAX_FOOD
	var needed_food := max_food - current_food
	if (needed_food <= 0):
		return

	var value := needed_food if source - needed_food > 0 else source
	source -= value
	player.eat(value)


func _on_fill_pressed() -> void:
	if is_in_range:
		var player := interactable_component.interactor
		on_fill(player)


func on_fill(player: Player) -> void:
	if player.resource_box == null: return
	var food_amount := player.resource_box.value
	source += food_amount
	player.empty_resource_box()


func enable_hud() -> void:
	food_icon.visible = true


func disable_hud() -> void:
	food_icon.visible = false
