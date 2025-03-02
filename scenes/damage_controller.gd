class_name DamageController
extends Node


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

	EventBus.machines_degraded.emit()

func damage_machines() -> void:
	var damage_count := get_damage_per_day(Data.game.day_number)
	var damage_distribution := _choose_rooms_and_machines(damage_count)
	_damage_machines(damage_distribution)


