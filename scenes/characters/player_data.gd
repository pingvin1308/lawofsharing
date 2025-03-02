
class_name PlayerData extends Resource

const MAX_WATER: int = 100
const MAX_FOOD: int = 100
const MAX_OXYGEN: int = 100

var is_ai: bool
## Should be received on game initialization
var player_index: int
var room_type: Data.ResourceType
var room_index: int
var resource_box: Data.ResourceBoxData

var water: int:
    set(value):
        water = clamp(value, 0, MAX_WATER)

var food: int:
    set(value):
        food = clamp(value, 0, MAX_FOOD)

var oxygen: int:
    set(value):
        oxygen = clamp(value, 0, MAX_OXYGEN)

@warning_ignore("shadowed_variable")
func _init(player_index: int, is_ai: bool = false) -> void:
    self.player_index = player_index
    self.is_ai = is_ai
    water = 80
    food = 80
    oxygen = 50