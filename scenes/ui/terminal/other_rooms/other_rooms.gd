class_name RoomsContainer
extends VBoxContainer

const ROOM_ITEM = preload("res://scenes/ui/terminal/other_rooms/room_item.tscn")
#var transfer_inputs: Array[TransferInput] = []

var player_room_index: int
var player_room_type: Data.ResourceType
var player_room_resource_value: int

@warning_ignore("shadowed_variable")
func initialize() -> void:
	var machine := Data.game.get_machine(Data.game.player.room_index, Data.game.player.room_type)
	player_room_resource_value = machine.source_value
	player_room_index = Data.game.player.room_index

	on_rooms_updated()
	EventBus.rooms_updated.connect(on_rooms_updated)
	EventBus.room_recourse_changed.connect(_on_room_recource_changed)


func on_rooms_updated() -> void:
	for child in get_children():
		#transfer_inputs.clear()
		child.queue_free()

	for room in Data.game.rooms:
		if room.room_index == Data.game.player.room_index:
			continue

		var room_item := ROOM_ITEM.instantiate() as RoomItem
		add_child(room_item)
		room_item.initialize(room)
		# сколькое место, может неправильно считаться сумма,
		# если кто то каким то чудом сможет ввести changed input в терминале прям в момент инициализации
		#transfer_inputs.append(room_item.transfer_input)
		#room_item.transfer_input.value_changed.connect(_on_value_changed)


#func _on_value_changed(sender: TransferInput) -> void:
	#var sum := 0
	#for input in transfer_inputs:
		#sum += input.changed_amount
#
	#if (sum > player_room_resource_value):
		#var diff := player_room_resource_value - sum
		#sender.spin_box.on_warning(player_room_type)
		#sender.spin_box.value += diff


func _on_room_recource_changed(room_index: int, type: Data.ResourceType, value: int) -> void:
	if room_index == player_room_index and type == player_room_type:
		player_room_resource_value = value
