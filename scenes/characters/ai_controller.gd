class_name AIController
extends InputController

# Define behavioral modes.
enum MODE { COOPERATIVE, DEDUCTIVE, GREEDY, AGGRESSIVE, CHAOTIC }

# Bot state variables.
var mode: int                # Current behavioral mode.
var resources: int = 100     # Overall resources.
var food: int = 50           # Food resource level.
var water: int = 50          # Water resource level.
var player_data: PlayerData


func _ready() -> void:
	# For example, assign a random mode at start-up.
	randomize()
	mode = MODE.COOPERATIVE #MODE.values()[randi() % 5]
	print("Mode selected: ", mode)

@warning_ignore("shadowed_variable")
func _init(ai_player_data: PlayerData) -> void:
	self.player_data = ai_player_data


func get_input_direction() -> Vector2:
	var direction := Vector2.ZERO
	return direction


func share_resources() -> void:
	# Decide whether to share resources.
	if mode == MODE.COOPERATIVE:
		# Share if resource levels are healthy.
		var machine := Data.game.get_machine(player_data.room_index, player_data.room_type)

		if machine.source_value > 0 :
			@warning_ignore("integer_division")
			var part_resource := 20

			for to_room_index in range(5):
				if to_room_index == player_data.room_index: continue
				if to_room_index != Data.game.player.room_index: continue

				for key: String in Data.ResourceType:
					var transfer := Data.TransferData.new(
						player_data.room_index,
						to_room_index,
						Data.ResourceType[key],
						part_resource)
					var receiver := Data.game.get_receiver(to_room_index)
					receiver.transfer_data_queue.push_back(transfer)
					EventBus.transfer_resources.emit(
						transfer.from_room_index,
						transfer.to_room_index,
						transfer.resource_type,
						transfer.value)

			print("Sharing resources with teammates.")
		else:
			print("Not enough resources to share.")
	elif mode == MODE.GREEDY:
		print("I'm greedy; I won't share.")
	elif mode == MODE.DEDUCTIVE:
		# Evaluate carefully before sharing.
		if resources > 80:
			print("Sharing after logical analysis.")
		else:
			print("Resources too low to share.")
	elif mode == MODE.AGGRESSIVE:
		print("Prefer attacking over sharing resources.")
	elif mode == MODE.CHAOTIC:
		# Random decision.
		if randi() % 2 == 0:
			print("Random decision: sharing resources.")
		else:
			print("Random decision: keeping resources.")

func restore_resources() -> void:

	var receiver := Data.game.get_receiver(player_data.room_index)
	if receiver.transfer_data_queue.size() > 0:
		var transfer_data: Data.TransferData = receiver.transfer_data_queue.pop_front()
		var machine := Data.game.get_machine(player_data.room_index, transfer_data.resource_type)
		machine.source_value += transfer_data.value
		EventBus.rooms_updated.emit()
		# EventBus.resources_transferred.emit(transfer_data.from_room_index, transfer_data.to_room_index, transfer_data.resource_type, transfer_data.value)

		print("Restoring resources from the receiver.")
	else:
		print("No resources to restore.")
	# Decide whether to use food and water now or wait.
	pass
	# if food < 20 or water < 20:
	# 	print("Critical levels! Restoring resources immediately.")
	# 	# Call restoration logic.
	# else:
	# 	match mode:
	# 		MODE.GREEDY:
	# 			print("Waiting to restore resources to stockpile more.")
	# 		MODE.COOPERATIVE:
	# 			print("Restoring resources to be ready for team support.")
	# 		MODE.AGGRESSIVE:
	# 			print("Skipping restoration in favor of offense.")
	# 		MODE.DEDUCTIVE:
	# 			print("Analyzing: might wait until tomorrow to restore.")
	# 		MODE.CHAOTIC:
	# 			if randi() % 2 == 0:
	# 				print("Random choice: restoring resources now.")
	# 			else:
	# 				print("Random choice: delaying restoration.")

func damage_machine() -> void:
	# Decide whether to damage a machine (i.e. break a container).
	match mode:
		MODE.AGGRESSIVE:
			print("Damaging machine to disrupt opponents.")
			# Insert damage logic here.
		MODE.GREEDY:
			if resources > 90:
				print("Damaging machine as a power move.")
			else:
				print("Saving resources, not damaging machine.")
		MODE.CHAOTIC:
			if randi() % 2 == 0:
				print("Random decision: damaging machine.")
			else:
				print("Random decision: leaving machine intact.")
		_:
			print("No machine damage this turn.")

func fix_machine() -> void:
	# Decide whether to fix a machine (i.e. repair a container for resource generation).
	match mode:
		MODE.COOPERATIVE, MODE.DEDUCTIVE:
			print("Fixing machine to secure resource production.")
			# Insert fixing logic here.
		MODE.GREEDY:
			print("Not fixing machine unless there's a personal benefit.")
		MODE.AGGRESSIVE:
			print("Ignoring repairs; focus is on offense.")
		MODE.CHAOTIC:
			if randi() % 2 == 0:
				print("Random decision: fixing machine.")
			else:
				print("Random decision: not fixing machine.")

func exchange_room() -> void:
	# Decide whether to exchange room based on a heuristic comparison.
	# The bot doesn't know room rank, so we simulate this using a placeholder score.
	var current_room_score := get_current_room_score()
	var neighbor_scores := get_neighbor_room_scores()
	var best_neighbor_score: int = max(neighbor_scores)

	if best_neighbor_score > current_room_score:
		match mode:
			MODE.DEDUCTIVE:
				print("Exchanging room after careful analysis.")
			MODE.AGGRESSIVE:
				print("Forcing room exchange to gain advantage.")
			MODE.CHAOTIC:
				if randi() % 2 == 0:
					print("Random decision: exchanging room.")
				else:
					print("Random decision: staying put.")
			# Cooperative and greedy might be opportunistic.
			MODE.COOPERATIVE, MODE.GREEDY:
				print("Exchanging room based on opportunity.")
	else:
		print("Current room is acceptable; no exchange.")

func get_current_room_score() -> int:
	# Placeholder: in your game this would be based on actual room attributes.
	return randi() % 100

func get_neighbor_room_scores() -> Array[int]:
	# Placeholder: simulate two neighboring room scores.
	return [randi() % 100, randi() % 100]
