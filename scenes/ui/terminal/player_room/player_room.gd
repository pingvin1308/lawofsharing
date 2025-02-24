class_name PlayerRoom
extends BoxContainer

@onready var room_name_label: Label = $RoomName
@onready var room_resources: PlayerRoomResources = $RoomResources

var room_index: int
var room_name: String:
	set(value):
		room_name = value
		room_name_label.text = "Current: " + room_name + " Room"


@warning_ignore("shadowed_variable")
func initialize() -> void:
	_on_player_room_changed()

	var machines := Data.game.get_machines(room_index)
	room_resources.initialize(machines)

	EventBus.player_room_changed.connect(_on_player_room_changed)
	EventBus.room_recource_changed.connect(_on_room_recource_changed)


func _on_player_room_changed() -> void:
	var player_room := Data.game.get_room(Data.game.player.room_type)
	self.room_name = player_room.room_name
	self.room_index = player_room.room_index


@warning_ignore("shadowed_variable")
func _on_room_recource_changed(room_index: int, type: Data.ResourceType, value: int) -> void:
	if self.room_index == room_index:
		room_resources.set_resource(type, value)
