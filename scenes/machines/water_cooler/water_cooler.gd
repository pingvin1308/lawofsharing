class_name WaterCooler
extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var control_menu: Control = $ControlMenu

var is_in_range: bool = false
var source: int = 100:
	set(value):
		source = clamp(value, 0, 100)
		label.text = str(source)


func _ready() -> void:
	source = 100


func _on_interactable_activated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()


func _on_interactable_deactivated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()


func _on_drink_drink() -> void:
	if is_in_range:
		var current_water = interactable_component.interactor.resources.water
		var max_water = interactable_component.interactor.resources.MAX_WATER
		var needed_water = max_water - current_water
		if (needed_water <= 0):
			return

		var value = needed_water if source - needed_water > 0 else source
		source -= value
		EventBus.machine_water_changed.emit(value)
