class_name MachineBase
extends StaticBody2D

@export var breakable_component: BreakableComponent

var data: Data.MachineData

var durability: int:
	get(): return data.durability if data else 0


func initialize(machine_data: Data.MachineData) -> void:
	data = machine_data
	if breakable_component:
		breakable_component.initialize(machine_data)


func damage() -> void:
	data.durability -= 1
	breakable_component.durability -= 1
