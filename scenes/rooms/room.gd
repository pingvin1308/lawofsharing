@tool
class_name Room
extends Node2D

@onready var room_tilemap: Node2D = $RoomTilemap

@onready var water_room_tilemap: Node2D = $RoomTilemap/WaterRoom
@onready var food_room_tilemap: Node2D = $RoomTilemap/FoodRoom
@onready var energy_room_tilemap: Node2D = $RoomTilemap/EnergyRoom
@onready var components_room_tilemap: Node2D = $RoomTilemap/ComponentsRoom
@onready var oxygen_room_tilemap: Node2D = $RoomTilemap/OxygenRoom

@onready var terminal: Terminal = $Terminal
@onready var sleep_room: SleepRoom = $SleepRoom
@onready var oxygen_timer: Timer = $OxygenTimer

@onready var water_cooler: WaterCooler = $WaterCooler
@onready var charger: Charger = $Charger
@onready var oxygen_balloons_stand: OxygenBalloons = $OxygenBalloonsStand
@onready var components_stand: ComponentsStand = $ComponentsStand
@onready var food_stand: FoodStand = $FoodStand

@onready var receiver: Receiver = $Receiver
@onready var sender: Sender = $Sender

@export var character_body: Player
@export var room_type: Data.ResourceType:
	set(value):
		if not self.is_node_ready(): await ready

		room_type = value

		for room: Node2D in room_tilemap.get_children():
			room.visible = false

		match value:
			Data.ResourceType.WATER:
				water_room_tilemap.visible = true
			Data.ResourceType.FOOD:
				food_room_tilemap.visible = true
			Data.ResourceType.ELECTRICITY:
				energy_room_tilemap.visible = true
			Data.ResourceType.COMPONENTS:
				components_room_tilemap.visible = true
			Data.ResourceType.OXYGEN:
				oxygen_room_tilemap.visible = true


var is_control_menu_opened: bool = false
## Key: String name, Machine
var machines_map: Dictionary = {}
## Key: Data.ResourceType, Value: MachineBase
var data: Data.RoomData

var room_index: int:
	get(): return data.room_index


func initialize(room_data: Data.RoomData, machines: Array[Data.MachineData]) -> void:
	data = room_data
	room_type = room_data.renewable_resource

	receiver.initialize(data.room_index)
	sender.initialize(data.room_index)

	for machine in machines:
		match machine.resource_type:
			Data.ResourceType.WATER:
				water_cooler.initialize(machine)
			Data.ResourceType.FOOD:
				food_stand.initialize(machine)
			Data.ResourceType.COMPONENTS:
				components_stand.initialize(machine)
			Data.ResourceType.ELECTRICITY:
				charger.initialize(machine)
			Data.ResourceType.OXYGEN:
				oxygen_balloons_stand.initialize(machine)

	oxygen_timer.timeout.connect(_on_oxygen_decreased)
	EventBus.terminal_menu_opened.connect(_menu_opened)
	EventBus.terminal_menu_closed.connect(_menu_closed)
	#EventBus.transfer_resources.connect(_on_transfer_resources)

	machines_map = {
		water_cooler.name: water_cooler,
		charger.name: charger,
		oxygen_balloons_stand.name: oxygen_balloons_stand,
		components_stand.name: components_stand,
		food_stand.name: food_stand,
		receiver.name: receiver,
		sender.name: sender
	}
	for machine_name: String in machines_map:
		@warning_ignore("unsafe_method_access")
		machines_map[machine_name].disable_hud()


func set_player(player: Player) -> void:
	character_body = player
	player.global_position = sleep_room.global_position + Vector2(24, 0)
	player.process_mode = PROCESS_MODE_INHERIT
	oxygen_timer.start(1.0)
	player.data.room_index = room_index
	player.data.room_type = room_type
	EventBus.player_changed_room.emit()

	for machine_name: String in machines_map:
		@warning_ignore("unsafe_method_access")
		machines_map[machine_name].enable_hud()


func unset_player() -> void:
	character_body.process_mode = PROCESS_MODE_DISABLED
	character_body = null
	oxygen_timer.stop()

	for machine_name: String in machines_map:
		@warning_ignore("unsafe_method_access")
		machines_map[machine_name].disable_hud()


func _menu_opened() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _menu_closed() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_oxygen_decreased() -> void:
	assert(character_body, "player cannot be outside of a room")
	var room_oxygen := oxygen_balloons_stand.source
	if room_oxygen > 0:
		oxygen_balloons_stand.source -= 1
		character_body.bearth(2)
