class_name FoodWaterController
extends Node


@export var food_cost: int = 10
@export var water_cost: int = 10


func decrease_food_and_water() -> void:
    Game.instance.player.data.food -= food_cost
    Game.instance.player.data.water -= water_cost

    for ai_player: Player in Game.instance.ai_players:
        ai_player.data.food -= food_cost
        ai_player.data.water -= water_cost

    EventBus.player_resource_changed.emit()
