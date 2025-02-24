class_name BreakableComponent
extends Node

const NAME: String = "BreakableComponent"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var control_menu: ControlMenu

var durability: int:
	get(): return machine_data.durability
	set(value):
		machine_data.durability = value
		_play_animation()

var machine_data: Data.MachineData


@warning_ignore("shadowed_variable")
func initialize(machine_data: Data.MachineData) -> void:
	self.machine_data = machine_data
	EventBus.machine_degradated.connect(on_machine_degradated)


func _ready() -> void:
	control_menu.break_pressed.connect(_on_break_pressed)
	control_menu.fix_pressed.connect(_on_fix_pressed)


func _on_break_pressed() -> void:
	durability -= 1


func _on_fix_pressed() -> void:
	durability += 1


func _play_animation() -> void:
	match durability:
		MAX_DURABILITY:
			animation_player.play("RESET")
			return
		DAMAGED_1:
			animation_player.play("damaged_1")
			return
		DAMAGED_2:
			animation_player.play("damaged_2")
			return
		BROKEN:
			animation_player.play("broken")
			return


func on_machine_degradated() -> void:
	durability = machine_data.durability


enum { BROKEN = 0, DAMAGED_2 = 1, DAMAGED_1 = 2, MAX_DURABILITY = 3 }
