class_name BreakableComponent
extends Node

const NAME: String = "BreakableComponent"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var break_machine: AudioStreamPlayer = $AudioManager/Break
@onready var fixing: AudioStreamPlayer = $AudioManager/Fixing


var durability: int:
	get(): return machine_data.durability
	set(value):
		machine_data.durability = value
		_play_animation()

var machine_data: Data.MachineData


@warning_ignore("shadowed_variable")
func initialize(machine_data: Data.MachineData) -> void:
	self.machine_data = machine_data
	EventBus.machine_degraded.connect(on_machine_degradated)


func on_break_pressed() -> void:
	var prev_durability := durability
	if prev_durability > 0:
		break_machine.play()
	durability -= 1


func on_fix_pressed() -> void:
	var prev_durability := durability
	if prev_durability < MAX_DURABILITY:
		fixing.play()
	durability += 1


func _play_animation() -> void:
	match machine_data.durability:
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
	_play_animation()


enum { BROKEN = 0, DAMAGED_2 = 1, DAMAGED_1 = 2, MAX_DURABILITY = 3 }
