class_name ResourceTransferController
extends Node


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
