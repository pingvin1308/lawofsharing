class_name VotingController
extends Node

#@onready var player_room: PlayerRoom = %PlayerRoom
#@onready var rooms_container: RoomsContainer = %RoomsContainer


@warning_ignore("shadowed_variable")
func initialize() -> void:

	# EventBus.room_exchange_vote()

	pass
	#player_room.initialize(player_room_data)
	#var other_rooms: Array[RoomData] = []
	#for room in rooms:
		#if room.room_index != player_room_data.room_index:
			#other_rooms.append(room)
	#rooms_container.initialize(player_room_data, other_rooms)
#
	#EventBus.terminal_menu_opened.connect(_on_open)
	#color_rect.gui_input.connect(on_click)
	#close.pressed.connect(on_close_pressed)


func on_vote() -> void:
	pass


func estimate_and_exchange_rooms(rooms: Array[Data.RoomData]) -> void:
	#db.Game.Rooms
	#db.Game.Player
	for room in rooms:
		extimate(room)

	pass

func extimate(room: Data.RoomData) -> float:
	const weight_water: float = 1.5
	const weight_food: float = 1.5
	const weight_oxygen: float = 2.0
	const weight_electricity: float = 1.0
	const weight_components: float = 0.8

	var room_machines := Data.game.get_machines(room.room_index)

	var score := 0.0
	for machine in room_machines:
		match machine.resource_type:
			Data.ResourceType.WATER:
				score += machine.source_value * weight_water
			Data.ResourceType.FOOD:
				score += machine.source_value * weight_food
			Data.ResourceType.COMPONENTS:
				score += machine.source_value * weight_components
			Data.ResourceType.ELECTRICITY:
				score += machine.source_value * weight_electricity
			Data.ResourceType.OXYGEN:
				score += machine.source_value * weight_oxygen


	return score
