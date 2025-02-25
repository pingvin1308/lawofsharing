class_name PlayerAnimations
extends AnimatedSprite2D


func play_animation(animation_name: String) -> void:
	if not animation_name.is_empty():
		play(animation_name)

func get_walk_animation_name(input_direction: Vector2) -> String:
	if input_direction.y < -0.5:
		return "walk_back"
	elif input_direction.y > 0.5:
		return "walk_front"
	elif input_direction.y > 0.5 and input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.y < 0.5 and input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.x > 0.5:
		return "walk_right"
	elif input_direction.y > -0.5 and input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.y < -0.5 and input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.x < -0.5:
		return "walk_left"
	elif input_direction.x > 0.5:
		return "walk_right"
	return ""

func get_idle_animation_name(input_direction: Vector2) -> String:
	if input_direction.y > 0.5:
		return "idle_front"
	elif input_direction.y < -0.5:
		return "idle_back"
	elif input_direction.x > 0.5:
		return "idle_right"
	elif input_direction.x < -0.5:
		return "idle_left"
	else:
		return "idle_front"
