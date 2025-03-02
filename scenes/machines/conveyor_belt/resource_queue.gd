class_name ResourceQueueContainer
extends Control

const RESOURCE_ITEM_ICON = preload("res://scenes/machines/conveyor_belt/room_transfer_data.tscn")

@onready var queue: VBoxContainer = $Queue


func update(transfer_data_queue: Array[Data.TransferData], send: bool = false) -> void:
	for room_transfer_data: RoomTransferData in queue.get_children():
		room_transfer_data.queue_free()

	for item in transfer_data_queue:
		var resource_item := RESOURCE_ITEM_ICON.instantiate() as RoomTransferData
		queue.add_child(resource_item)

		var room_index := item.to_room_index if send else item.from_room_index
		var room := Data.game.get_room_by_filter(
			func(r: Data.RoomData) -> bool:
				return r.room_index == room_index)
    
		resource_item.add(item, room.renewable_resource)
