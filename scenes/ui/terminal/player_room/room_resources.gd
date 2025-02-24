class_name PlayerRoomResources
extends GridContainer

@onready var oxygen_label: Label = $Oxygen/OxygenLabel
@onready var energy_label: Label = $Energy/EnergyLabel
@onready var food_label: Label = $Food/FoodLabel
@onready var components_label: Label = $Components/ComponentsLabel
@onready var water_label: Label = $Water/WaterLabel


func initialize(machines: Array[Data.MachineData]) -> void:
	for machine in machines:
		set_resource(machine.resource_type, machine.source_value)


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
