class_name SleepRoom
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent

var is_in_range: bool = false


func _on_interactable_activated() -> void:
	#(sprite_2вd.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true


func _on_interactable_deactivated() -> void:
	#(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
