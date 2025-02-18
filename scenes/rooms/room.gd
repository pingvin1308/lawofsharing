class_name Room
extends Node2D

@export var character_body: CharacterBody2D

@onready var water_cooler: WaterCooler = $WaterCooler
@onready var charger: Charger = $Charger
@onready var terminal: Terminal = $Terminal
@onready var oxygen_balloons_stand: OxygenBalloons = $OxygenBalloonsStand
@onready var components_stand: ComponentsStand = $ComponentsStand
@onready var food_stand: FoodStand = $FoodStand

var is_control_menu_opened: bool = false


func _ready() -> void:
	#get_

	if character_body:
		character_body.init(self)
