@tool
class_name Room
extends Node2D

@onready var room_tilemap: Node2D = $RoomTilemap

@onready var water_room: Node2D = $RoomTilemap/WaterRoom
@onready var food_room: Node2D = $RoomTilemap/FoodRoom
@onready var energy_room: Node2D = $RoomTilemap/EnergyRoom
@onready var components_room: Node2D = $RoomTilemap/ComponentsRoom
@onready var oxygen_room: Node2D = $RoomTilemap/OxygenRoom

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
				water_room.visible = true
			Data.ResourceType.FOOD:
				food_room.visible = true
			Data.ResourceType.ELECTRICITY:
				energy_room.visible = true
			Data.ResourceType.COMPONENTS:
				components_room.visible = true
			Data.ResourceType.OXYGEN:
				oxygen_room.visible = true



var is_control_menu_opened: bool = false
## Key: String name, Machine
var breakable_machines: Dictionary = {}
## Key: Data.ResourceType, Value: MachineBase
var resources_map: Dictionary
var data: Data.RoomData

var room_index: int:
	get(): return data.room_index


func initialize(room_data: Data.RoomData, machines: Array[Data.MachineData]) -> void:
	data = room_data

	receiver.initialize(data.room_index)

	match room_data.renewable_resource:
		Data.ResourceType.WATER:
			water_room.visible = true
		Data.ResourceType.FOOD:
			food_room.visible = true
		Data.ResourceType.ELECTRICITY:
			energy_room.visible = true
		Data.ResourceType.COMPONENTS:
			components_room.visible = true
		Data.ResourceType.OXYGEN:
			oxygen_room.visible = true

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

	resources_map = {
		Data.ResourceType.WATER: water_cooler,
		Data.ResourceType.FOOD: food_stand,
		Data.ResourceType.COMPONENTS: components_stand,
		Data.ResourceType.ELECTRICITY: charger,
		Data.ResourceType.OXYGEN: oxygen_balloons_stand,
	}

	oxygen_timer.timeout.connect(_on_oxygen_decreased)
	EventBus.terminal_menu_opened.connect(_menu_opened)
	EventBus.terminal_menu_closed.connect(_menu_closed)
	EventBus.transfer_resources.connect(_on_transfer_resources)

	breakable_machines = {
		water_cooler.name: water_cooler,
		charger.name: charger,
		oxygen_balloons_stand.name: oxygen_balloons_stand,
		components_stand.name: components_stand,
		food_stand.name: food_stand
	}


func set_player(player: Player) -> void:
	character_body = player
	player.global_position = sleep_room.global_position + Vector2(24, 0)
	player.process_mode = PROCESS_MODE_INHERIT
	oxygen_timer.start(1.0)
	player.data.room_index = room_index
	player.data.room_type = room_type
	EventBus.player_changed_room.emit()


func unset_player() -> void:
	character_body.process_mode = PROCESS_MODE_DISABLED
	character_body = null
	oxygen_timer.stop()


func _menu_opened() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _menu_closed() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_oxygen_decreased() -> void:
	assert(character_body, "player cannot be outside of a room")
	var room_oxygen := oxygen_balloons_stand.source
	if room_oxygen > 0:
		oxygen_balloons_stand.source  -= 1
		character_body.oxygen += 2


@warning_ignore("shadowed_variable")
func _on_transfer_resources(room_source_index: int, room_index: int, resource_type: Data.ResourceType, changed_amount: int) -> void:
	if self.room_index == room_source_index:
		_set_resource(resource_type, -changed_amount)
	elif self.room_index == room_index:
		_set_resource(resource_type, changed_amount)


func _set_resource(resource_type: Data.ResourceType, changed_amount: int) -> void:
	match resource_type:
		Data.ResourceType.WATER:
			if water_cooler.durability <= 0:
				return
			water_cooler.source += changed_amount

		Data.ResourceType.FOOD:
			if food_stand.durability <= 0:
				return
			food_stand.source += changed_amount

		Data.ResourceType.COMPONENTS:
			if components_stand.durability <= 0:
				return
			components_stand.source += changed_amount

		Data.ResourceType.ELECTRICITY:
			if charger.durability <= 0:
				return
			charger.source += changed_amount

		Data.ResourceType.OXYGEN:
			if oxygen_balloons_stand.durability <= 0:
				return
			oxygen_balloons_stand.source += changed_amount
