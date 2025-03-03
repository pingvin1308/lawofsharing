class_name Player
extends CharacterBody2D

@onready var animations: PlayerAnimations = $AnimatedSprite2D
@onready var oxygen_timer: Timer = $OxygenTimer
@onready var audio_manager: PlayerAudioManager = $AudioManager
@onready var control_menu: ControlMenu = $ControlMenu
@onready var resource_item_icon: ResourceItemIcon = $ResourceItemIcon
@onready var camera: Camera2D = $Camera2D

@export var speed: int = 100
@export var lerp_speed: float = 50
@export var lerp_velocity_value_on_floor: float = 16


@export var max_speed: int = 100
@export var acceleration: int = 5
@export var friction: int = 8


var input_controller: InputController
var previous_direction: Vector2 = Vector2.ZERO
var data: PlayerData

var oxygen: int:
	get(): return data.oxygen

var water: int:
	get(): return data.water

var food: int:
	get(): return data.food

var resource_box: Data.ResourceBoxData:
	get(): return data.resource_box

var is_died: bool:
	get(): return data.oxygen == 0 or data.water == 0 or data.food == 0


func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED


func initialize(player_data: PlayerData = null) -> void:
	data = player_data

	if data.is_ai == false:
		camera.zoom = Vector2(1.2, 1.2)
		input_controller = InputController.new()
	else:
		input_controller = AIController.new(data)

	control_menu.visible = false
	control_menu.modulate.a = 0
	control_menu.action_pressed.connect(_on_action_pressed)
	oxygen_timer.timeout.connect(_on_timeout)
	oxygen_timer.autostart = false
	oxygen_timer.stop();


func _physics_process(delta: float) -> void:
	if is_died:
		oxygen_timer.stop()
		return

	var input_direction := input_controller.get_input_direction()
	_move_character(input_direction, delta)

	if input_direction.is_zero_approx():
		var idle_animation := animations.get_idle_animation_name(previous_direction)
		animations.play_animation(idle_animation)
	else:
		previous_direction = input_direction.normalized()
		var walk_animation := animations.get_walk_animation_name(input_direction)
		animations.play_animation(walk_animation)


func _move_character(input_direction: Vector2, delta: float) -> void:
	var lerp_weight := delta * (acceleration if input_direction else friction)
	var calculated_velocity: Vector2 = lerp(velocity, input_direction * max_speed, lerp_weight)
	velocity = calculated_velocity
	move_and_slide()


func _on_timeout() -> void:
	data.oxygen -= 1

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


func breath(oxygen_amount: int) -> void:
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
	control_menu.modulate.a = 1.0


func _on_action_pressed() -> void:
	drop_box()


func drop_box() -> void:
	if resource_box == null: return
	var box_scene := ResourceBox.make()
	var player_room : Room = Data.game.get_by_filter(
		Game.instance.rooms,
		func(r: Room) -> bool: return r.room_index == data.room_index)
	player_room.add_child(box_scene)
	box_scene.initialize(data.resource_box)
	box_scene.global_position = global_position
	empty_resource_box()


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
