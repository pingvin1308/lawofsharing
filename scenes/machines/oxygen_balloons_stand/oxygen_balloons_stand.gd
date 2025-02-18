class_name OxygenBalloons
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var control_menu: Control = $ControlMenu

var is_in_range: bool = false
var source: int = 500:
	set(value):
		source = clamp(value, 0, 500)
		label.text = str(source)


func _ready() -> void:
	source = 500
	EventBus.player_oxygen_changed.connect(_on_player_oxygen_changed)


func _on_interactable_activated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()


func _on_interactable_deactivated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()


func _on_player_oxygen_changed(value: int):
	source += value
	label.text = str(source)


func _unhandled_input(event: InputEvent) -> void:
	pass
	#if is_in_range && event.is_action_pressed("interact"):
		#var current_electricity = interactable_component.interactor.resources.electricity
		#var max_electricity = interactable_component.interactor.resources.MAX_ELECTRICITY
		#var needed_electricity = max_electricity - current_electricity
		#if (needed_electricity <= 0):
			#return
#
		#var value = needed_electricity if source - needed_electricity > 0 else source
		#source -= value
		#EventBus.machine_electricity_changed.emit(value)
