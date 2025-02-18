extends Node

const MAX_WATER: int = 100
const MAX_FOOD: int = 100
const MAX_OXYGEN: int = 100
const MAX_ELECTRICITY: int = 100
const MAX_COMPONENTS: int = 100

@export var water: int = MAX_WATER
@export var food: int = MAX_FOOD
@export var oxygen: int = MAX_OXYGEN
@export var electricity: int = MAX_ELECTRICITY
@export var components: int = MAX_COMPONENTS

var room_rank: int:
	get():
		# Весовые коэффициенты
		var weight_water = 1.5  # Вода очень важна
		var weight_food = 1.5  # Еда тоже важна
		var weight_oxygen = 2.0  # Без кислорода смерть
		var weight_electricity = 1.0  # Важно для комнаты
		var weight_components = 0.8  # Менее важно, но влияет на состояние

		# Расчет оценки
		var score = (
			water * weight_water +
			food * weight_food +
			oxygen * weight_oxygen +
			electricity * weight_electricity +
			components * weight_components
		)
		return score
