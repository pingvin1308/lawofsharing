class_name Player
extends CharacterBody2D

const RESOURCE_BOX = preload("res://scenes/machines/resource_box.tscn")
@onready var animations: PlayerAnimations = $AnimatedSprite2D
@onready var oxygen_timer: Timer = $OxygenTimer
@onready var audio_manager: PlayerAudioManager = $AudioManager
@onready var control_menu: ControlMenu = $ControlMenu
@onready var resource_item_icon: ResourceItemIcon = $ResourceItemIcon
@onready var camera: Camera2D = $Camera2D

@export var speed: int = 100
@export var lerp_speed: float = 50
@export var lerp_velocity_value_on_floor: float = 16

var input_controller: InputController
var direction: Vector2 = Vector2.ZERO
var data: Data.PlayerData

var oxygen: int:
	get(): return data.oxygen

var water: int:
	get(): return data.water

var food: int:
	get(): return data.food

var resource_box: Data.ResourceBoxData:
	get(): return data.resource_box

var is_died: bool:
	get(): return oxygen == 0 or water == 0 or food == 0


func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	control_menu.modulate.a = 0


func initialize(player_data: Data.PlayerData) -> void:
	if player_data.is_ai == false:
		($Camera2D as Camera2D).zoom = Vector2(1.2, 1.2)
		input_controller = InputController.new()
	else:
		input_controller = AIController.new(player_data)
		player_data.ai_controller = input_controller

	data = player_data
	oxygen_timer.timeout.connect(_on_timeout)
	control_menu.action_pressed.connect(_on_action_pressed)


func _physics_process(delta: float) -> void:
	var input_direction := input_controller.get_input_direction()
	if input_direction.is_zero_approx():
		var idle_animation := animations.get_idle_animation_name(direction)
		animations.play_animation(idle_animation)
		return

	_move_character(input_direction, delta)
	var walk_animation := animations.get_walk_animation_name(direction)
	animations.play_animation(walk_animation)


func _move_character(input_direction: Vector2, delta: float) -> void:
	if input_direction.is_zero_approx():
		return

	direction = lerp(direction, Vector2(input_direction.x, input_direction.y).normalized(), delta * lerp_speed)

	var calculated_velocity := velocity
	var move_x := direction.x * speed
	var move_y := direction.y * speed
	if direction:
		calculated_velocity = Vector2(move_x, move_y)
	else:
		calculated_velocity = Vector2(
			lerp(calculated_velocity.x, move_x, delta * lerp_velocity_value_on_floor),
			lerp(calculated_velocity.y, move_y, delta * lerp_velocity_value_on_floor)
		)

	direction = direction
	velocity = calculated_velocity
	move_and_slide()


func _on_timeout() -> void:
	oxygen -= 1

func drink(water_amount: int) -> void:
	if water_amount <= 0: return
	data.water += water_amount
	audio_manager.drink.play()
	EventBus.player_resource_changed.emit()


func eat(food_amount: int) -> void:
	if food_amount <= 0: return
	data.food += food_amount
	audio_manager.eating.play()
	EventBus.player_resource_changed.emit()


func bearth(oxygen_amount: int) -> void:
	if oxygen_amount <= 0: return
	data.oxygen += oxygen_amount
	EventBus.player_resource_changed.emit()


@warning_ignore("shadowed_variable")
func pickup_box(resource_box: Data.ResourceBoxData) -> void:
	data.resource_box = resource_box
	control_menu.action_name = "drop"
	control_menu.enable()
	resource_item_icon.visible = true
	resource_item_icon.icon.texture = ResourcesRepository.resources[resource_box.resource_type].icon
	resource_item_icon.label.text = str(resource_box.value)
	#var tween := get_tree().create_tween()
	#tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)
	control_menu.modulate.a = 1.0


func drop_box() -> void:
	if resource_box == null: return
	var box_scene := RESOURCE_BOX.instantiate() as ResourceBox
	get_parent().add_child(box_scene)
	box_scene.initialize(data.resource_box)
	box_scene.position = position
	empty_resource_box()


func _on_action_pressed() -> void:
	drop_box()

func empty_resource_box() -> void:
	data.resource_box = null
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)
	resource_item_icon.visible = false
	control_menu.action_name = ""
	control_menu.visible = false

func enable_commands_panel(action_name: String) -> void:
	control_menu.visible = true
	control_menu.action_name = action_name


func disable_commands_panel() -> void:
	control_menu.visible = false
	control_menu.action_name = ""
