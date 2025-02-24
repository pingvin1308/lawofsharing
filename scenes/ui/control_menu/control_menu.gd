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

@export var action_name: String
@export var is_breakable: bool = true

func _ready() -> void:
	if action_name:
		action.text = action_name
	else:
		action.visible = false
		action.process_mode = Node.PROCESS_MODE_DISABLED

	if not is_breakable:
		fix.visible = false
		fix.process_mode = Node.PROCESS_MODE_DISABLED
		break_button.visible = false
		break_button.process_mode = Node.PROCESS_MODE_DISABLED


func enable() -> void:
	visible = true


func disable() -> void:
	visible = false


func _on_action_pressed() -> void:
	action_pressed.emit()


func _on_fix_pressed() -> void:
	fixing.play()
	fix_pressed.emit()


func _on_break_pressed() -> void:
	break_machine.play()
	break_pressed.emit()
