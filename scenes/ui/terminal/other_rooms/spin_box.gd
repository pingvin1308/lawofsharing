class_name ResourceInput
extends SpinBox

@onready var warning: Panel = $Warning
@onready var label: Label = $Warning/Label

func _make_custom_tooltip(for_text: String) -> Tooltip:
	var tooltip := preload("res://scenes/ui/tooltip/tooltip.tscn").instantiate() as Tooltip
	tooltip.text = for_text
	return tooltip

func on_warning(resource_type: Data.ResourceType) -> void:
	warning.visible = true
	var resource_name: String = Data.ResourceType.keys()[resource_type]
	label.text = "Has not more " + resource_name
	await get_tree().create_timer(0.5).timeout
	warning.visible = false
