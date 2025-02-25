class_name ResourceBox
extends StaticBody2D

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var control_menu: ControlMenu = $ControlMenu
@onready var label: Label = $ResourceIcon/Label
@onready var icon: TextureRect = $ResourceIcon/Icon

var resource_type_icon_map: Dictionary = {
	Data.ResourceType.WATER: 0,
	Data.ResourceType.COMPONENTS: 1,
	Data.ResourceType.ELECTRICITY: 2,
	Data.ResourceType.OXYGEN: 3,
	Data.ResourceType.FOOD: 4,
}

var is_in_range: bool
var data: Data.ResourceBoxData


func _ready() -> void:
	control_menu.action_name = "take"
	control_menu.modulate.a = 0
	interactable_component.interactable_activated.connect(_on_interactable_activated)
	interactable_component.interactable_deactivated.connect(_on_interactable_deactivated)
	control_menu.action_pressed.connect(_on_action_pressed)


func initialize(resource_box_data: Data.ResourceBoxData) -> void:
	self.data = resource_box_data
	label.text = str(data.value)
	icon.texture = ResourcesRepository.resources[data.resource_type].icon
	sprite_2d.frame = resource_type_icon_map[data.resource_type]


func _on_interactable_activated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", true)
	is_in_range = true
	control_menu.enable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 1.0, 0.2)


func _on_interactable_deactivated() -> void:
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("is_enabled", false)
	is_in_range = false
	control_menu.disable()
	var tween := get_tree().create_tween()
	tween.tween_property(control_menu, "modulate:a", 0.0, 0.2)


func _on_action_pressed() -> void:
	if is_in_range:
		var player = interactable_component.interactor
		if player.resource_box != null:
			Notification.instance.show_warning("You already have box with resource")
			return

		player.pickup_box(data)
		queue_free()
