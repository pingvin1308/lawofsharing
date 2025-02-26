class_name TargetRoomMenu
extends Control

@onready var room_types: OptionButton = $Panel/MarginContainer/GridContainer/RoomTypes

var selected_room: Data.ResourceType:
	get():
		#last_selected =
		return room_types.get_selected_id() as Data.ResourceType

var last_selected: Data.ResourceType


func _ready() -> void:
	room_types.get_popup().id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id: int) -> void:
	last_selected = id as Data.ResourceType


func enable(exclude_type: Data.ResourceType) -> void:
	room_types.clear()
	for resource_name: String in Data.ResourceType:
		if Data.ResourceType[resource_name] == exclude_type: continue
		var resource_type: Data.ResourceType = Data.ResourceType[resource_name]
		var resource_item: ResourceItem = ResourcesRepository.resources[resource_type]
		room_types.add_icon_item(resource_item.icon, resource_item.room_name, resource_type)

	for resource_name: String in Data.ResourceType:
		var resource_type: Data.ResourceType = Data.ResourceType[resource_name]
		if last_selected == resource_type:
			room_types.select(resource_type)

	visible = true


func disable() -> void:
	visible = false
	room_types.clear()
