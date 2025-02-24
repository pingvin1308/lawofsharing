extends Node


@warning_ignore("unused_signal")
signal player_resource_changed()
@warning_ignore("unused_signal")
signal player_room_changed()
@warning_ignore("unused_signal")
signal player_food_eaten(value: int)
@warning_ignore("unused_signal")
signal player_water_drunk(value: int)
@warning_ignore("unused_signal")
signal player_changed_room()


@warning_ignore("unused_signal")
signal machine_degradated()


@warning_ignore("unused_signal")
signal terminal_menu_opened()
@warning_ignore("unused_signal")
signal terminal_menu_closed()
@warning_ignore("unused_signal")
signal terminal_day_ended()


@warning_ignore("unused_signal")
signal room_recource_changed(room_index: int, type: Data.ResourceType, value: int)
@warning_ignore("unused_signal")
signal rooms_updated()


@warning_ignore("unused_signal")
signal transfer_resources(room_source_index: int, room_index: int, resource_type: Data.ResourceType, changed_amount: int)
