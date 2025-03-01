class_name RoomItem
extends BoxContainer

#@onready var transfer_input: TransferInput = $ResourcesMenu/Transfer
@onready var vote_button: CheckButton = $ResourcesMenu/VoteButton
@onready var room_name_label: Label = $Name

@onready var oxygen_label: Label = $ResourcesMenu/RoomResources/Oxygen/OxygenLabel
@onready var energy_label: Label = $ResourcesMenu/RoomResources/Energy/EnergyLabel
@onready var food_label: Label = $ResourcesMenu/RoomResources/Food/FoodLabel
@onready var components_label: Label = $ResourcesMenu/RoomResources/Components/ComponentsLabel
@onready var water_label: Label = $ResourcesMenu/RoomResources/Water/WaterLabel

var map: Dictionary
var room_name: String
var room_index: int = -1
var room_type: Data.ResourceType
#var changed_amount: int:
	#get():
		#return transfer_input.changed_amount


@warning_ignore("shadowed_variable")
func initialize(room_data: Data.RoomData) -> void:
	room_index = room_data.room_index
	room_name = room_data.room_name
	room_name_label.text = room_data.room_name + " room"
	room_type = room_data.renewable_resource

	var machines := Data.game.get_machines(room_index)
	for machine in machines:
		set_resource(machine.resource_type, machine.source_value)

	#transfer_input.initialize()
	map = {
		Data.ResourceType.WATER: water_label,
		Data.ResourceType.FOOD: food_label,
		Data.ResourceType.COMPONENTS: components_label,
		Data.ResourceType.ELECTRICITY: energy_label,
		Data.ResourceType.OXYGEN: oxygen_label,
	}

	assert(room_index != -1, "Room index should be initialized")
	#EventBus.terminal_day_ended.connect(_on_terminal_day_ended)
	EventBus.room_recourse_changed.connect(_on_room_resource_changed)


#func _on_terminal_day_ended() -> void:
	#if transfer_input.changed_amount > 0:
		#EventBus.transfer_resources.emit(transfer_input.room_source_index, room_index, transfer_input.resource_type, transfer_input.changed_amount)
	#transfer_input.reset_changes()


@warning_ignore("shadowed_variable")
func _on_room_resource_changed(room_index: int, type: Data.ResourceType, value: int) -> void:
	if self.room_index == room_index:
		set_resource(type, value)

func set_resource(resource_type: Data.ResourceType, value: int) -> void:
	match resource_type:
		Data.ResourceType.WATER:
			water_label.text = str(value)
		Data.ResourceType.COMPONENTS:
			components_label.text = str(value)
		Data.ResourceType.ELECTRICITY:
			energy_label.text = str(value)
		Data.ResourceType.FOOD:
			food_label.text = str(value)
		Data.ResourceType.OXYGEN:
			oxygen_label.text = str(value)
