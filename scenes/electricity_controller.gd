class_name ElectricityController
extends Node

@export var required_electricity: int = 20


## Decrease charge in all chargers and return rooms indexes that are out of charge.
func decrease_charge() -> Array[int]:
    var rooms_out_of_charge: Array[int] = []
    for charger: Charger in Game.instance.chargers:
        charger.source -= required_electricity
        if charger.source <= 0:
            rooms_out_of_charge.append(charger.data.room_index)

    return rooms_out_of_charge

