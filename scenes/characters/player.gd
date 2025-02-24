class_name Player
extends CharacterBody2D

var input_controller: InputController
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var oxygen_timer: Timer = $OxygenTimer
@onready var audio_manager: PlayerAudioManager = $AudioManager

@export var speed: int = 100
@export var lerp_speed: float = 50
@export var lerp_velocity_value_on_floor: float = 16

var direction: Vector2 = Vector2.ZERO
var data: Data.PlayerData

var oxygen: int:
	get(): return data.oxygen
	set(value):
		data.oxygen = value
		EventBus.player_resource_changed.emit()


func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED


func initialize(player_data: Data.PlayerData) -> void:
	if player_data.is_ai == false:
		($Camera2D as Camera2D).zoom = Vector2(1.2, 1.2)
		input_controller = InputController.new()
	else:
		input_controller = AIController.new(player_data)
		player_data.ai_controller = input_controller

	data = player_data
	EventBus.player_water_drunk.connect(_on_player_water_drunk)
	EventBus.player_food_eaten.connect(_on_player_food_eaten)
	oxygen_timer.timeout.connect(_on_timeout)


func _physics_process(delta: float) -> void:
	var input_direction := input_controller.get_input_direction()
	if input_direction.is_zero_approx():
		var animation_name := _get_idle_animation_name(direction)
		animated_sprite_2d.play(animation_name)
		return

	_move_character(input_direction, delta)
	_play_animation(input_direction)


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


func _on_player_water_drunk(value: int) -> void:
	audio_manager.drink.play()
	data.water += value
	EventBus.player_resource_changed.emit()


func _on_player_food_eaten(value: int) -> void:
	audio_manager.eating.play()
	data.food += value
	EventBus.player_resource_changed.emit()


func _play_animation(input_direction: Vector2) -> void:
	var animation_name := _get_walk_animation_name(input_direction)
	if not animation_name.is_empty():
		animated_sprite_2d.play(animation_name)

func _get_walk_animation_name(input_direction: Vector2) -> String:
	if input_direction.y < -0.5:
		return "walk_back"
	elif input_direction.y > 0.5:
		return "walk_front"
	elif input_direction.y > 0.5 and input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.y < 0.5 and input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.y > -0.5 and input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.y < -0.5 and input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.x > 0.5:
		return "walk_right"
	return ""

func _get_idle_animation_name(input_direction: Vector2) -> String:
	if input_direction.y > 0.5:
		return "idle_front"
	elif input_direction.y < -0.5:
		return "idle_back"
	elif input_direction.x > 0.5:
		return "idle_right"
	elif input_direction.x < -0.5:
		return "idle_left"
	else:
		return "idle_front"

func _on_timeout() -> void:
	oxygen -= 1
