class_name Sender
extends StaticBody2D

const RESOURCE_BOX = preload("res://scenes/machines/resource_box.tscn")
const TOOLTIP = preload("res://scenes/ui/tooltip/tooltip.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var control_menu: ControlMenu = $ControlMenu
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var resource_queue: ResourceQueueContainer = $ResourceQueue

var is_in_range: bool
var resource_box_on_belt: ResourceBox
var data: Data.SenderData


func _ready() -> void:
	control_menu.action_name = "send"
	control_menu.modulate.a = 0
	control_menu.action_pressed.connect(_open_rooms_map)
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)

func initialize(room_index: int) -> void:
	control_menu.modulate.a = 0
	data = Data.game.get_sender(room_index)
	EventBus.resources_transferred.connect(_on_resources_transferred)


func _on_interactable_activated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)
	tween.parallel()


func _on_interactable_deactivated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)
	tween.parallel()

var previous_camera_global_position: Vector2
var is_menu_opened: bool

var tmp_tween: Tween

func _open_rooms_map() -> void:
	if is_menu_opened:
		return

	MapButtonBack.instance.pressed.connect(close_rooms_map)
	var player: Player = get_tree().get_first_node_in_group("player")
	player.speed = 0

	var camera := get_viewport().get_camera_2d()
	previous_camera_global_position = camera.global_position
	tmp_tween = create_tween()
	tmp_tween.tween_property(camera, "zoom", Vector2(0.3, 0.3), 1)
	tmp_tween.parallel()
	tmp_tween.tween_property(camera, "global_position", Vector2.ZERO, 1)
	await tmp_tween.finished
	camera.zoom = Vector2(0.3, 0.3)
	camera.global_position = Vector2.ZERO

	is_menu_opened = true
	EventBus.rooms_menu_opened.emit()


func close_rooms_map() -> void:
	if not is_menu_opened:
		return

	MapButtonBack.instance.pressed.disconnect(close_rooms_map)

	var camera: Camera2D = get_viewport().get_camera_2d()
	tmp_tween = create_tween()
	tmp_tween.tween_property(camera, "zoom", Vector2(1.2, 1.2), 1)
	tmp_tween.parallel()
	tmp_tween.tween_property(camera, "global_position", previous_camera_global_position, 1)
	await tmp_tween.finished
	camera.zoom = Vector2(1.2, 1.2)
	camera.global_position = previous_camera_global_position

	var player: Player = get_tree().get_first_node_in_group("player")
	player.speed = 90
	is_menu_opened = false
	EventBus.rooms_menu_closed.emit()


func _process(_delta: float) -> void:
	var is_left_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if tmp_tween && is_left_click:
		tmp_tween.set_speed_scale(4)


func _unhandled_input(event: InputEvent) -> void:
	if not is_menu_opened:
		return

	if event.is_action_pressed(&"exit"):
		close_rooms_map()


func on_send_resource(player: Player, target_room_index: int) -> void:
	if player.resource_box == null:
		Notification.instance.show_warning("Nothing to send. Take a resource box first!")
		return
	var resource_box := player.resource_box
	player.empty_resource_box()

	var transfer_data: Data.TransferData = Data.TransferData.new(
		data.room_index,
		target_room_index,
		resource_box.resource_type,
		resource_box.value)

	animated_sprite_2d.play()
	var box := RESOURCE_BOX.instantiate() as ResourceBox
	get_parent().add_child(box)
	box.initialize(resource_box)
	box.position = position + spawn_point.position
	box.z_index = 1

	var tween := get_tree().create_tween().bind_node(box)
	tween.tween_property(box, "global_position", box.global_position + Vector2(-33, 0), 0.6)
	tween.tween_callback(func() -> void:
		if box:
			box.queue_free()
			data.transfer_data_queue.push_back(transfer_data)
			resource_queue.update(data.transfer_data_queue, true)
		animated_sprite_2d.stop())
	
	while (box != null):
		#TODO: подумать о том как можно выкинуть сообщение для игрока, после пойманной коробки
		if player.resource_box == resource_box:
			Notification.instance.show_warning("Wow! That was impressive!")
		await get_tree().process_frame


func enable_hud() -> void:
	resource_queue.visible = true


func disable_hud() -> void:
	resource_queue.visible = false


func _on_resources_transferred() -> void:
	resource_queue.update(data.transfer_data_queue, true)


func get_resource_from_queue() -> Data.TransferData:
	var item: Data.TransferData = data.transfer_data_queue.pop_front()
	resource_queue.update(data.transfer_data_queue, true)
	return item