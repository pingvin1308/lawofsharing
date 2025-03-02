extends Node

const MAX_SOURCE_VALUE: int = 500
const MAX_DURABILITY: int = 3
var game: GameData


class GameData extends Resource:
	var day_number: int = 0

	# DATA
	var rooms: Array[RoomData] = []
	var player: PlayerData
	var ai_players: Array[PlayerData]
	var machines: Array[MachineData] = []
	var votes: Array[VoteData] = []
	var receivers: Array[ReceiverData] = []
	var senders: Array[SenderData] = []
	var tooltip: Tooltip
	var rooms_menu_opened: bool = false

	@warning_ignore("shadowed_variable")
	func _init(rooms: Array[RoomData], player: PlayerData, machines: Array[MachineData], ai_players: Array[PlayerData]) -> void:
		self.rooms = rooms
		self.player = player
		self.machines = machines
		self.ai_players = ai_players


	func get_room(resource_type: ResourceType) -> RoomData:
		for room in rooms:
			if room.renewable_resource == resource_type:
				return room
		return null

	## filter with Callable[Room, bool]
	func get_room_by_filter(filter: Callable) -> RoomData:
		for room in rooms:
			if (filter.call(room) as bool):
				return room
		return null

	func get_by_filter(collection: Array[Variant], filter: Callable) -> Variant:
		for item: Variant in collection:
			if (filter.call(item) as bool):
				return item
		return null


	func get_machines(room_index: int) -> Array[MachineData]:
		var result: Array[MachineData] = []
		for machine in machines:
			if machine.room_index == room_index:
				result.append(machine)
		return result


	func get_machine(room_index: int, resource_type: ResourceType) -> MachineData:
		for machine in machines:
			if machine.room_index == room_index and machine.resource_type == resource_type:
				return machine
		return null

	func get_receiver(room_index: int) -> ReceiverData:
		for receiver in receivers:
			if receiver.room_index == room_index:
				return receiver
		return null

	func get_sender(room_index: int) -> SenderData:
		for sender in senders:
			if sender.room_index == room_index:
				return sender
		return null


class RoomData extends Resource:
	## Should be received on game initialization
	var room_index: int
	var renewable_resource: ResourceType
	var room_name: String:
		get(): return ResourceType.keys()[renewable_resource]

	@warning_ignore("shadowed_variable")
	func _init(room_index: int, renewable_resource: ResourceType) -> void:
		self.room_index = room_index
		self.renewable_resource = renewable_resource


class MachineData extends Resource:
	## Should be received on game initialization
	var room_index: int
	var resource_type: ResourceType

	var durability: int:
		set(value):
			durability = clamp(value, 0, MAX_DURABILITY)

	var source_value: int:
		set(value):
			source_value = clamp(value, 0, MAX_SOURCE_VALUE)


	@warning_ignore("shadowed_variable")
	func _init(room_index: int, resource_type: ResourceType) -> void:
		self.room_index = room_index
		self.resource_type = resource_type
		self.durability = MAX_DURABILITY
		self.source_value = 100

		if resource_type == ResourceType.OXYGEN:
			self.source_value = 500


class VoteData extends Resource:
	var day: int
	var player_index: int
	var from_room_index: int
	var to_room_index: int


class ReceiverData extends Resource:
	var room_index: int
	var transfer_data_queue: Array[TransferData] = []

	@warning_ignore("shadowed_variable")
	func _init(room_index: int) -> void:
		self.room_index = room_index


class SenderData extends Resource:
	var room_index: int
	var transfer_data_queue: Array[TransferData] = []

	@warning_ignore("shadowed_variable")
	func _init(room_index: int) -> void:
		self.room_index = room_index


class TransferData extends Resource:
	var from_room_index: int
	var to_room_index: int
	var resource_type: ResourceType
	var value: int

	@warning_ignore("shadowed_variable")
	func _init(from_room_index: int, to_room_index: int, resource_type: ResourceType, value: int) -> void:
		self.from_room_index = from_room_index
		self.to_room_index = to_room_index
		self.resource_type = resource_type
		self.value = value


class ResourceBoxData extends Resource:
	var resource_type: ResourceType
	var value: int

	@warning_ignore("shadowed_variable")
	func _init(resource_type: ResourceType, value: int) -> void:
		self.resource_type = resource_type
		self.value = value

enum ResourceType {WATER, FOOD, COMPONENTS, ELECTRICITY, OXYGEN}
