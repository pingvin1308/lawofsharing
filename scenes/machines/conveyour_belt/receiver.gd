class_name Receiver
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

var data: Data.ReceiverData

func _ready() -> void:
	control_menu.modulate.a = 0
	control_menu.action_pressed.connect(_on_action_pressed)
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)
	EventBus.transfer_resources.connect(_on_transfer_resources)


func initialize(room_index: int) -> void:
	data = Data.game.get_receiver(room_index)


func _on_interactable_activated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)


func _on_interactable_deactivated() -> void:
	(animated_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)


func _on_transfer_resources(_room_source_index: int, to_room_index: int, _resource_type: Data.ResourceType, _changed_amount: int) -> void:
	if data.room_index == to_room_index:
		resource_queue.update(data.transfer_data_queue)


func _on_action_pressed() -> void:
	if resource_box_on_belt != null:
		var scene := TOOLTIP.instantiate() as Tooltip
		scene.text = "Take resource from the belt"
		scene.background_color = "ff0000"
		scene.position = position
		scene.z_index = 1
		get_parent().add_child(scene)
		await get_tree().create_timer(1.0).timeout
		scene.queue_free()
		return

	if data.transfer_data_queue.is_empty():
		var scene := TOOLTIP.instantiate() as Tooltip
		scene.text = "No resources"
		scene.background_color = "ff0000"
		scene.position = position
		scene.z_index = 1
		get_parent().add_child(scene)
		await get_tree().create_timer(1.0).timeout
		scene.queue_free()
		return

	var transfer_data: Data.TransferData = data.transfer_data_queue.pop_front()
	resource_queue.update(data.transfer_data_queue)

	animated_sprite_2d.play()
	var box_data := Data.ResourceBoxData.new(transfer_data.resource_type, transfer_data.value)
	var box := RESOURCE_BOX.instantiate() as ResourceBox
	box.position = position + spawn_point.position
	box.z_index = 1
	get_parent().add_child(box)

	box.initialize(box_data)
	resource_box_on_belt = box
	var tween := get_tree().create_tween()
	tween.tween_property(box, "global_position", box.global_position + Vector2(-33, 0), 0.6)
	tween.tween_callback(func() -> void: animated_sprite_2d.stop())
