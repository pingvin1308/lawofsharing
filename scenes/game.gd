class_name Game
extends Node2D

@onready var player: Player = $Player
@onready var ai_player: Player = $AIPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var damage_controller: DamageController = $DamageController

@onready var rooms_controller: RoomsController = $RoomsController
@onready var terminal_menu: TerminalMenu = $CanvasLayer/TerminalMenu
@onready var hud: HUD = $CanvasLayer/HUD
@onready var voting_controller: VotingController = $VotingController
var days_passed: int = 0


var ai_players: Array[Player] = []
var rooms: Array[Room] = []
var receivers: Array[Receiver] = []
var senders: Array[Sender] = []

#var scenary
# tutorial vs real surv

# init day: light food and water needs
# next day: resource recovery
# next day: send resources
# next day: your receive some resources
# next day: degradation rules
# next day: room exchage (vote + break)
# next day: just survive 5 days
# other players might be
#  cooperative with every ooe,
#  be cooperate only with you,
#  be greedy
#  be aggresive
#  be chaotic
@onready var tutorial: TutorialMenu = $CanvasLayer/Tutorial


func _ready() -> void:
	if tutorial.visible:
		tutorial.finished.connect(_on_finished)
	else:
		player.speed = 90
		call_deferred("initialize")


func _on_finished() -> void:
	call_deferred("initialize")


func initialize() -> void:
	canvas_layer.follow_viewport_enabled = false
	var player_data := PlayerData.new(0)
	var rooms_data: Array[Data.RoomData] = []
	var machines: Array[Data.MachineData] = []
	var receivers_data: Array[Data.ReceiverData] = []
	var senders_data: Array[Data.SenderData] = []

	for index in Data.ResourceType.keys().size():
		var room_data := Data.RoomData.new(index, index)
		rooms_data.append(room_data)

		for resource_type: Data.ResourceType in Data.ResourceType.values():
			var machine := Data.MachineData.new(index, resource_type)
			machines.append(machine)

		var receiver: Data.ReceiverData = Data.ReceiverData.new(index)
		receivers_data.append(receiver)

		var sender: Data.SenderData = Data.SenderData.new(index)
		senders_data.append(sender)

	ai_players = [ai_player]
	var ai_player_data := PlayerData.new(0, true)
	var ai_players_data: Array[PlayerData] = [ai_player_data]

	Data.game = Data.GameData.new(
		rooms_data,
		player_data,
		machines,
		ai_players_data)
	Data.game.receivers = receivers_data
	Data.game.senders = senders_data


	player.initialize(player_data)
	ai_player.initialize(ai_player_data)
	rooms_controller.initialize(player, ai_player)
	#voting_controller.initialize(
		#rooms_controller.player_room_data,
		#rooms_controller.rooms)
	terminal_menu.initialize()
	hud.initialize()

	for room in rooms_controller.get_children():
		if room is Room:
			rooms.append(room)
			receivers.append((room as Room).receiver)
			senders.append((room as Room).sender)

	EventBus.terminal_day_ended.connect(_on_day_ended)


func _process(_delta: float) -> void:
	if player.is_died:
		print("Game over!")


func _on_day_ended() -> void:
	# check if game finished
	# check goals

	_transfer_resources()
	damage_controller.damage_machines()

	Data.game.day_number += 1

	for ai_player: Player in ai_players:
		assert(ai_player.input_controller is AIController)
		(ai_player.input_controller as AIController).restore_resources()
		(ai_player.input_controller as AIController).share_resources()

	# damage_machines()
	# exchange_rooms()

	EventBus.rooms_updated.emit()
	pass


func _transfer_resources() -> void:
	for sender: Sender in senders:
		while not sender.data.transfer_data_queue.is_empty():
			var item: Data.TransferData = sender.get_resource_from_queue()
			var target_receiver: Receiver = Data.game.get_by_filter(
				receivers,
				func(x: Receiver) -> bool: return x.data.room_index == item.to_room_index)

			if target_receiver == null:
				continue

			target_receiver.on_resource_received(item)

	# EventBus.resources_transferred.emit()