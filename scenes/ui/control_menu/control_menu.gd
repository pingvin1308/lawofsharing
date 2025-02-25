class_name ControlMenu
extends Control

signal action_pressed()
signal fix_pressed()
signal break_pressed()

@onready var action: Button = $Action
@onready var fix: Button = $Fix
@onready var break_button: Button = $Break
@onready var break_machine: AudioStreamPlayer = $AudioManager/Break
@onready var fixing: AudioStreamPlayer = $AudioManager/Fixing

var is_breakable: bool

var action_name: String:
	get(): return action.text
	set(value):
		if not self.is_node_ready(): await ready
		action.text = value


func enable() -> void:
	fix.visible = is_breakable
	break_button.visible = is_breakable
	action.visible = not action_name.is_empty()
	visible = true


func disable() -> void:
	visible = false


func _on_action_pressed() -> void:
	assert(not action_name.is_empty(), "Action without name cannot be triggered")
	action_pressed.emit()


func _on_fix_pressed() -> void:
	fixing.play()
	fix_pressed.emit()


func _on_break_pressed() -> void:
	break_machine.play()
	break_pressed.emit()
