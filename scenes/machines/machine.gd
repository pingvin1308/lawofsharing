class_name MachineBase
extends StaticBody2D

@onready var breakable_component: BreakableComponent = $BreakableComponent
@onready var control_menu: ControlMenu = $ControlMenu

var data: Data.MachineData

var durability: int:
	get(): return data.durability if data else 0

var resource_type: Data.ResourceType:
	get(): return data.resource_type


func initialize(machine_data: Data.MachineData) -> void:
	control_menu.modulate.a = 0
	data = machine_data
	if breakable_component:
		breakable_component.initialize(machine_data)
		control_menu.is_breakable = true
		control_menu.break_pressed.connect(breakable_component.on_break_pressed)
		control_menu.fix_pressed.connect(breakable_component.on_fix_pressed)


func enable_hud() -> void:
	pass


func disable_hud() -> void:
	pass
