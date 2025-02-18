class_name InputController
extends Node

func get_input_direction() -> Vector2:
	return Input.get_vector(&"walk_left", &"walk_right", &"walk_up", &"walk_down")
