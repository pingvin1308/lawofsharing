class_name TransferInput
extends BoxContainer

signal value_changed(sender: TransferInput)

@onready var icon: TextureRect = $ResourceData/Icon
#@onready var label: Label = $ResourceData/Label

@onready var transfer_amount: Label = $TransferMenu/TransferAmount
@onready var reset: Button = $TransferMenu/Reset
@onready var spin_box: ResourceInput = $TransferMenu/SpinBox

@export var changedColor: Color
@export var resource_icon: Texture2D

var room_source_index: int
var resource_type: Data.ResourceType
var is_changed: bool = false
var changed_amount: int = 0:
	set(value):
		changed_amount = clamp(value, 0, 999)
		transfer_amount.text = str(changed_amount)

		if changed_amount == 0:
			_reset_styles()
			return

		transfer_amount.add_theme_color_override("font_color", changedColor)
		is_changed = true
		reset.visible = true


func initialize() -> void:
	var room_type := Data.game.player.room_type
	var room := Data.game.get_room(room_type)
	var machine := Data.game.get_machine(room.room_index, room_type)

	var renewable_resource_value := machine.source_value
	_set_player_room_resource(
		room.room_index,
		room_type,
		renewable_resource_value)

	spin_box.max_value = Data.MAX_SOURCE_VALUE
	spin_box.value_changed.connect(on_value_changed)
	spin_box.get_line_edit().text_changed.connect(on_text_changed)
	reset.pressed.connect(reset_changes)


func _set_player_room_resource(room_index: int, room_type: Data.ResourceType, _renewable_resource_value: int) -> void:
	room_source_index = room_index
	resource_type = room_type
	icon.texture = ResourcesRepository.resources[room_type].icon


func on_value_changed(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	changed_amount = value
	value_changed.emit(self)

func on_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		reset_changes()


func reset_changes() -> void:
	changed_amount = 0
	_reset_styles()


func _reset_styles() -> void:
	spin_box.release_focus()
	spin_box.set_value_no_signal(0.0)
	is_changed = false
	reset.visible = false
	transfer_amount.remove_theme_color_override("font_color")
