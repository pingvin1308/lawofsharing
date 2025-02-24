class_name ResourceQueueContainer
extends Control

const RESOURCE_ITEM_ICON = preload("res://scenes/machines/resource_item_icon.tscn")

@onready var queue: HBoxContainer = $HBoxContainer


func update(transfer_data_queue: Array[Data.TransferData]) -> void:
	for item: ResourceItemIcon in queue.get_children():
		item.queue_free()

	for item in transfer_data_queue:
		var resource_item := RESOURCE_ITEM_ICON.instantiate() as ResourceItemIcon
		queue.add_child(resource_item)
		resource_item.icon.texture = ResourcesRepository.resources[item.resource_type].icon
		resource_item.label.text = str(item.value)
