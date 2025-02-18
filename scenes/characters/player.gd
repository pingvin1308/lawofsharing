class_name Player
extends CharacterBody2D

@onready var input_controller: InputController = $InputController
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var resources: CharacterResources = $CharacterResources
@onready var oxygen_timer: Timer = $OxygenTimer
@onready var oxygen_label: Label = $OxygenLabel

@export var speed: int = 100
@export var lerp_speed: float = 50
@export var lerp_velocity_value_on_floor: float = 16

var direction: Vector2 = Vector2.ZERO
var current_room: Room


func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	EventBus.machine_water_changed.connect(_on_machine_water_changed)
	EventBus.machine_food_changed.connect(_on_machine_food_changed)
	oxygen_timer.timeout.connect(_on_oxygen_decreased)
	oxygen_label.text = str(resources.oxygen)


func init(room: Room) -> void:
	current_room = room
	process_mode = PROCESS_MODE_INHERIT


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

func _on_machine_water_changed(value: int) -> void:
	resources.water += value


func _on_machine_food_changed(value: int) -> void:
	resources.food += value


func _on_oxygen_decreased() -> void:
	assert(current_room, "player cannot be outside of a room")
	var room_oxygen = current_room.oxygen_balloons_stand.source
	if room_oxygen > 0:
		current_room.oxygen_balloons_stand.source -= 1
	else:
		resources.oxygen -= 1
		oxygen_label.text = str(resources.oxygen)


func _play_animation(input_direction: Vector2) -> void:
	var animation_name = _get_walk_animation_name(input_direction)
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
