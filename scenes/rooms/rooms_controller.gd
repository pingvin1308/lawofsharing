class_name RoomsController
extends Node2D

var player_room: Room


@warning_ignore("shadowed_variable")
func initialize(player: Player, ai_player: Player) -> void:
	for room: Room in get_children():
		assert(room is Room, "'RoomsController' should contains only 'Room' nodes")
		var room_data := Data.game.get_room(room.room_type)
		var room_machines := Data.game.get_machines(room_data.room_index)
		room.initialize(room_data, room_machines)

		room.room_option.pressed.connect(
			func() -> void: _on_send_room_selected(room.room_index))

	var room_indexes: Array[int] = []
	for i in get_child_count():
		room_indexes.push_back(i)
	room_indexes.shuffle()

	var player_room_index: int = room_indexes.pop_front()
	player_room = get_child(player_room_index) as Room
	player_room.set_player(player)

	var ai_player_room_index: int = room_indexes.pop_front()
	var ai_player_room := get_child(ai_player_room_index) as Room
	ai_player_room.set_player(ai_player)


func _on_send_room_selected(selected_room_index: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	await player_room.sender.close_rooms_map()
	await player_room.sender.on_send_resource(player, selected_room_index)
