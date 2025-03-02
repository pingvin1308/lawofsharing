class_name RoomTransferData
extends HBoxContainer

const RESOURCE_ITEM_ICON = preload("res://scenes/machines/resource_item_icon.tscn")
@onready var room_background_color: PanelContainer = $RoomBackgroundColor
@onready var room_label: Label = $RoomBackgroundColor/RoomLabel


func add(item: Data.TransferData, room_resource_type: Data.ResourceType) -> void:
    var resource_item := RESOURCE_ITEM_ICON.instantiate() as ResourceItemIcon
    add_child(resource_item)
    move_child(resource_item, 0)
    resource_item.icon.texture = ResourcesRepository.resources[item.resource_type].icon
    resource_item.label.text = str(item.value)

    match room_resource_type:
        Data.ResourceType.WATER:
            room_background_color.self_modulate = Color.from_string("456b89", Color.WHITE)
            room_label.text = "W"
        Data.ResourceType.FOOD:
            room_background_color.self_modulate = Color.from_string("755f45", Color.WHITE)
            room_label.text = "F"
        Data.ResourceType.OXYGEN:
            room_background_color.self_modulate = Color.from_string("6b9acf", Color.WHITE)
            room_label.text = "O"
        Data.ResourceType.ELECTRICITY:
            room_background_color.self_modulate = Color.from_string("606e64", Color.WHITE)
            room_label.text = "E"
        Data.ResourceType.COMPONENTS:
            room_background_color.self_modulate = Color.from_string("585858", Color.WHITE)
            room_label.text = "C"

