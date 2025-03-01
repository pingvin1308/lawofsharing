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

		room.room_option.pressed.connect(_on_send_room_selected)

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

	EventBus.terminal_day_ended.connect(_on_day_ended)


# Функция определения количества повреждений на день
func get_damage_per_day(day: int) -> int:
	if day <= 3:
		return [1, 2].pick_random() if randf() < 0.7 else 2
	elif day <= 6:
		return [2, 3].pick_random()
	else:
		return [3, 4].pick_random() if randf() < 0.6 else 3


# Функция выбора комнат для поломок
func _choose_rooms_and_machines(damage_count: int) -> Dictionary:
	var room_names: Array[Data.RoomData] = Data.game.rooms
	var chosen_rooms: Array[String] = []

	# Выбираем случайные комнаты (ограничение: max 2 поломки в одной)
	for i in range(damage_count):
		var room: Data.RoomData = room_names.pick_random()
		if chosen_rooms.count(room.room_name) < 2:
			chosen_rooms.append(room.room_name)

	# Подсчет повреждений по комнатам
	var damage_distribution := {}
	for room_name in chosen_rooms:
		damage_distribution[room_name] = damage_distribution.get(room_name, 0) + 1

	return damage_distribution


# Функция выбора машин внутри комнаты
func _damage_machines(damage_distribution: Dictionary) -> void:
	for room_name: String in damage_distribution.keys():
		var damage: int = damage_distribution[room_name]
		var available_machines: Array[Data.MachineData] = []

		# Выбираем только машины, у которых прочность больше 0

		for machine in Data.game.machines:
			if machine.durability > 0:
				available_machines.append(machine)

		# Если есть доступные машины, наносим урон случайным
		if available_machines.size() > 0:
			var chosen_machines := available_machines.duplicate()
			chosen_machines.shuffle()
			chosen_machines = chosen_machines.slice(0, min(chosen_machines.size(), damage))

			for chosen_machine: Data.MachineData in chosen_machines:
				var machine := Data.game.get_machine(chosen_machine.room_index, chosen_machine.resource_type)
				machine.durability -= 1
				print("Повреждена", machine, "в", room_name, "Осталось прочности:", machine.durability)

			EventBus.machine_degraded.emit()

func damage_machines() -> void:
	var damage_count := get_damage_per_day(Data.game.day_number)
	var damage_distribution := _choose_rooms_and_machines(damage_count)
	_damage_machines(damage_distribution)


func _on_day_ended() -> void:
	Data.game.day_number += 1
	for ai_player in Data.game.ai_players:
		ai_player.ai_controller.share_resources()

	damage_machines()

	EventBus.rooms_updated.emit()


func _on_send_room_selected() -> void:
	var player := get_tree().get_first_node_in_group("player")
	await player_room.sender.close_rooms_map()
	await player_room.sender.on_send_resource(player, player_room.room_index)
