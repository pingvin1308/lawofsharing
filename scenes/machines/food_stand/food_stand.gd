class_name FoodStand
extends ResourceContainerBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $FoodIcon/Label
@onready var food_icon: Control = $FoodIcon

var room_name: String
var is_in_range: bool = false

var source: int:
	get(): return data.source_value
	set(value):
		data.source_value = value
		EventBus.room_recourse_changed.emit(data.room_index, Data.ResourceType.FOOD, data.source_value)
		label.text = str(data.source_value)


func _ready() -> void:
	control_menu.modulate.a = 0
	control_menu.take_pressed.connect(_on_take_pressed)
	control_menu.action_pressed.connect(_on_eat_pressed)


func set_source(value: int) -> void:
	source = value


func _on_interactable_activated() -> void:
	var interactor := interactable_component.interactor;
	if interactor.resource_box != null and interactor.resource_box.resource_type == Data.ResourceType.FOOD:
		_enable_fill()
	else:
		_enable_eat()

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
	var max_food := PlayerData.MAX_FOOD
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
	_enable_eat()


func enable_hud() -> void:
	food_icon.visible = true


func disable_hud() -> void:
	food_icon.visible = false


func _enable_fill() -> void:
	control_menu.action_name = "fill"
	control_menu.connect_signals(_on_fill_pressed)
	control_menu.disconnect_signals(_on_eat_pressed)


func  _enable_eat() -> void:
	control_menu.action_name = "eat"
	control_menu.connect_signals(_on_eat_pressed)
	control_menu.disconnect_signals(_on_fill_pressed)


func _on_take_pressed() -> void:
	if interactable_component.interactor != null:
		var player := interactable_component.interactor
		_on_take(player)


func _on_take(player: Player) -> void:
	if source <= 0: return
	var source_amount := 5
	source -= source_amount

	if player.resource_box != null and player.resource_box.resource_type != resource_type:
		Notification.instance.show_warning(
			"You can't take resource, drop your box with: " + str(player.resource_box.resource_type))

	var amount := source_amount \
		if player.data.resource_box == null \
		else player.resource_box.value + source_amount

	var box_data := Data.ResourceBoxData.new(
		resource_type,
		amount)
	player.pickup_box(box_data)
	_enable_fill()
