class_name HUD
extends Control

@onready var food: Label = $MarginContainer/HBoxContainer/HBoxContainer/Food
@onready var water: Label = $MarginContainer/HBoxContainer/HBoxContainer2/Water
@onready var oxygen: Label = $MarginContainer/HBoxContainer/HBoxContainer3/Oxygen


func initialize() -> void:
	EventBus.player_resource_changed.connect(_on_player_resource_changed)
	_on_player_resource_changed()


func _on_player_resource_changed() -> void:
	food.text = str(Data.game.player.food) + "/" + str(Data.game.player.MAX_FOOD)
	water.text = str(Data.game.player.water) + "/" + str(Data.game.player.MAX_WATER)
	oxygen.text = str(Data.game.player.oxygen) + "/" + str(Data.game.player.MAX_OXYGEN)
