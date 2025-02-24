class_name Tooltip
extends Control

@export var label: Label

@export var background_color: Color:
	set(value):
		background_color = value
		modulate = value

@export var text: String:
	set(value):
		text = value
		label.text = text
