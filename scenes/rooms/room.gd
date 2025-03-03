@tool
class_name Room
extends Node2D

# TILEMAP CONFIGURATION
@onready var room_tilemap: Node2D = $RoomTilemap
@onready var water_room_tilemap: Node2D = $RoomTilemap/WaterRoom
@onready var food_room_tilemap: Node2D = $RoomTilemap/FoodRoom
@onready var energy_room_tilemap: Node2D = $RoomTilemap/EnergyRoom
@onready var components_room_tilemap: Node2D = $RoomTilemap/ComponentsRoom
@onready var oxygen_room_tilemap: Node2D = $RoomTilemap/OxygenRoom

@export var color1: Color
@export var color2: Color
@export var color3: Color
@export var color4: Color

# GUI
@onready var room_option: Button = $RoomOption

# MACHINES
@onready var terminal: Terminal = $Terminal
@onready var sleep_room: SleepRoom = $SleepRoom
@onready var water_cooler: WaterCooler = $WaterCooler
@onready var charger: Charger = $Charger
@onready var oxygen_balloons_stand: OxygenBalloons = $OxygenBalloonsStand
@onready var components_stand: ComponentsStand = $ComponentsStand
@onready var food_stand: FoodStand = $FoodStand

# TRANSFER DEVICES
@onready var receiver: Receiver = $Receiver
@onready var sender: Sender = $Sender

@onready var oxygen_timer: Timer = $OxygenTimer
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


# ROOM DATA
## Key: String name, Machine
var machines_map: Dictionary = {}
## Key: Data.ResourceType, Value: MachineBase
var data: Data.RoomData

var room_index: int:
	get(): return data.room_index


func initialize(room_data: Data.RoomData, machines: Array[Data.MachineData]) -> void:
	oxygen_timer.autostart = false
	oxygen_timer.stop()

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
	charger.electricity_changed.connect(_on_electricity_changed)
	EventBus.terminal_menu_opened.connect(_menu_opened)
	EventBus.terminal_menu_closed.connect(_menu_closed)
	EventBus.rooms_menu_opened.connect(_on_rooms_menu_opened)
	EventBus.rooms_menu_closed.connect(_on_rooms_menu_closed)
	# room_option.pressed.connect(_on_send_room_selected)
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
	player.position = sleep_room.position + Vector2(24, 0)
	player.process_mode = PROCESS_MODE_INHERIT
	oxygen_timer.start()
	player.data.room_index = room_index
	player.data.room_type = room_type
	player.oxygen_timer.start()
	EventBus.player_changed_room.emit()
	Game.instance.remove_child(player)
	add_child(player)

	if not player.data.is_ai:
		for machine_name: String in machines_map:
			@warning_ignore("unsafe_method_access")
			machines_map[machine_name].enable_hud()


func unset_player() -> void:
	add_child(character_body)
	Game.instance.add_child(character_body)
	character_body.process_mode = PROCESS_MODE_DISABLED
	character_body = null
	oxygen_timer.stop()

	for machine_name: String in machines_map:
		@warning_ignore("unsafe_method_access")
		machines_map[machine_name].disable_hud()


func _on_rooms_menu_opened() -> void:
	if Data.game.player.room_index == room_index:
		return
	room_option.visible = true


func _on_rooms_menu_closed() -> void:
	room_option.visible = false


func _menu_opened() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _menu_closed() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_oxygen_decreased() -> void:
	assert(character_body, "player cannot be outside of a room")
	var room_oxygen := oxygen_balloons_stand.source
	if room_oxygen > 0:
		oxygen_balloons_stand.source -= 1
		character_body.breath(2)


func _on_electricity_changed() -> void:
	var color: Color
	if charger.source >= 80:
		color = color1
	if charger.source < 80:
		color = color2
	if charger.source <= 40:
		color = color3
	if charger.source <= 20:
		color = color4

	modulate = color
