class_name ResourceTransferController
extends Node


@export var restore_oxygen_amount: int = 500
@export var restore_components_amount: int = 100
@export var restore_food_amount: int = 100
@export var restore_water_amount: int = 100
@export var restore_electricity_amount: int = 100

func transfer_resources() -> void:
	for sender: Sender in Game.instance.senders:
		while not sender.data.transfer_data_queue.is_empty():
			var item: Data.TransferData = sender.get_resource_from_queue()
			var target_receiver: Receiver = Data.game.get_by_filter(
				Game.instance.receivers,
				func(x: Receiver) -> bool: return x.data.room_index == item.to_room_index)

			if target_receiver == null:
				continue

			target_receiver.on_resource_received(item)

	# EventBus.resources_transferred.emit()


func restore_renewable_resources() -> void:
	for room: Room in Game.instance.rooms:
		match room.data.renewable_resource:
			Data.ResourceType.OXYGEN:
				room.oxygen_balloons_stand.source += restore_oxygen_amount
			Data.ResourceType.COMPONENTS:
				room.components_stand.source += restore_components_amount
			Data.ResourceType.FOOD:
				room.food_stand.source += restore_food_amount
			Data.ResourceType.WATER:
				room.water_cooler.source += restore_water_amount
			Data.ResourceType.ELECTRICITY:
				room.charger.source += restore_electricity_amount