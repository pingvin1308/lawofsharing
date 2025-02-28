class_name Sender
extends StaticBody2D

const RESOURCE_BOX = preload("res://scenes/machines/resource_box.tscn")
const TOOLTIP = preload("res://scenes/ui/tooltip/tooltip.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var control_menu: ControlMenu = $ControlMenu
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var target_room_menu: TargetRoomMenu = $TargetRoomMenu
@onready var resource_queue: ResourceQueueContainer = $ResourceQueue

var is_in_range: bool
var resource_box_on_belt: ResourceBox
var data: Data.SenderData


func _ready() -> void:
	control_menu.action_name = "send"
	control_menu.modulate.a = 0
	target_room_menu.modulate.a = 0
	control_menu.action_pressed.connect(_on_action_pressed)
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)

func initialize(room_index: int) -> void:
	control_menu.modulate.a = 0
	data = Data.game.get_sender(room_index)
	EventBus.resources_transfered.connect(_on_resources_transfered)


func _on_interactable_activated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()
	var room := Data.game.get_room_by_filter(
		func(r: Data.RoomData) -> bool: return r.room_index == data.room_index)
	#target_room_menu.enable(room.renewable_resource)
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)
	tween.parallel()
	tween.tween_property(target_room_menu, "modulate:a", 1.0, 0.2)


func _on_interactable_deactivated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()
	target_room_menu.disable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)
	tween.parallel()
	tween.tween_property(target_room_menu, "modulate:a", 0.0, 0.2)

var previous_camera_global_position: Vector2
var is_menu_opened: bool

func _on_action_pressed() -> void:
	if is_menu_opened:
		return

	MapButtonBack.instance.pressed.connect(_on_map_button_back_pressed)
	var camera = get_viewport().get_camera_2d()
	previous_camera_global_position = camera.global_position
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(0.3, 0.3), 1)
	tween.parallel()
	tween.tween_property(camera, "global_position", Vector2.ZERO, 1)

	var player = get_tree().get_first_node_in_group("player")

	player = interactable_component.interactor
	player.speed = 0
	is_menu_opened = true
	#player.process_mode = PROCESS_MODE_DISABLED
	#on_send_resource(player)


func _on_map_button_back_pressed() -> void:
	if not is_menu_opened:
		return

	MapButtonBack.instance.pressed.disconnect(_on_map_button_back_pressed)
	var camera = get_viewport().get_camera_2d()
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.2, 1.2), 1)
	tween.parallel()
	var player = get_tree().get_first_node_in_group("player")
	tween.tween_property(camera, "global_position", previous_camera_global_position, 1)
	await tween.finished
	#player.process_mode = Node.PROCESS_MODE_INHERIT
	player.speed = 90
	is_menu_opened = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_menu_opened:
		return

	if event.is_action_pressed(&"exit"):
		_on_map_button_back_pressed()



#func on_send_resource(player: Player) -> void:
	#if player.resource_box == null:
		#Notification.instance.show_warning("Nothing to send")
		#return
	#var resource_box := player.resource_box
	#player.empty_resource_box()
#
	#var tween := get_tree().create_tween()
	#var transfer_data: Data.TransferData = Data.TransferData.new(
		#data.room_index,
		#target_room_menu.selected_room,
		#resource_box.resource_type,
		#resource_box.value)
#
	#animated_sprite_2d.play()
	#var box := RESOURCE_BOX.instantiate() as ResourceBox
	#get_parent().add_child(box)
	##box.current_tween = tween
	#box.initialize(resource_box)
	#box.position = position + spawn_point.position
	#box.z_index = 1
#
	#tween.tween_property(box, "global_position", box.global_position + Vector2(-33, 0), 0.6)
	#tween.tween_callback(func() -> void:
		#if box != null:
			#box.queue_free()
#
		##if is_instance_valid(box):
			##data.transfer_data_queue.push_back(transfer_data)
			##resource_queue.update(data.transfer_data_queue)
		##elif player.resource_box == resource_box:
			##Notification.instance.show_warning("Wow!")
			##tween.kill()
		#animated_sprite_2d.stop())


func on_send_resource(player: Player) -> void:
	if player.resource_box == null:
		Notification.instance.show_warning("Nothing to send")
		return
	var resource_box := player.resource_box
	player.empty_resource_box()

	var transfer_data: Data.TransferData = Data.TransferData.new(
		data.room_index,
		target_room_menu.selected_room,
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
			resource_queue.update(data.transfer_data_queue)
		animated_sprite_2d.stop())
	await tween.finished

	#TODO: подумать о том как можно выкинуть сообщение для игрока, после пойманной коробки
	if player.resource_box == resource_box:
		Notification.instance.show_warning("Wow!")


func enable_hud() -> void:
	resource_queue.visible = true


func disable_hud() -> void:
	resource_queue.visible = false


func _on_resources_transfered() -> void:
	resource_queue.update(data.transfer_data_queue)
