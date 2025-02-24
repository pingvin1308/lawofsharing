class_name Sender
extends StaticBody2D

const RESOURCE_BOX = preload("res://scenes/machines/resource_box.tscn")
const TOOLTIP = preload("res://scenes/ui/tooltip/tooltip.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var control_menu: ControlMenu = $ControlMenu
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var spawn_point: Marker2D = $SpawnPoint

var is_in_range: bool
var resource_box_on_belt: ResourceBox


func _ready() -> void:
	control_menu.modulate.a = 0
	control_menu.action_pressed.connect(_on_action_pressed)
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)


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

func _on_action_pressed() -> void:
	pass
	#if resource_box_on_belt != null:
		#var scene := TOOLTIP.instantiate() as Tooltip
		#scene.text = "Take resource from the belt"
		#scene.background_color = "ff0000"
		#scene.position = position
		#scene.z_index = 1
		#get_parent().add_child(scene)
		#await get_tree().create_timer(1.0).timeout
		#scene.queue_free()
		#return
#
	#animated_sprite_2d.play()
	#var box := RESOURCE_BOX.instantiate() as ResourceBox
	#resource_box_on_belt = box
	#box.position = position + spawn_point.position
	#box.z_index = 1
	#get_parent().add_child(box)
	#var tween := get_tree().create_tween()
	#tween.tween_property(box, "global_position", box.global_position + Vector2(-33, 0), 0.6)
	#tween.tween_callback(func() -> void: animated_sprite_2d.stop())
