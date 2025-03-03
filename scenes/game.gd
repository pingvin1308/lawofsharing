class_name Game
extends Node2D

static var instance: Game

@onready var player: Player = $Player
@onready var ai_player: Player = $AIPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var rooms_controller: RoomsController = $RoomsController
@onready var terminal_menu: TerminalMenu = $CanvasLayer/TerminalMenu
@onready var hud: HUD = $CanvasLayer/HUD
@onready var main_menu: MainMenu = $CanvasLayer/MainMenu

@onready var electricity_controller: ElectricityController = $ElectricityController
@onready var resource_transfer_controller: ResourceTransferController = $ResourceTransferController
@onready var damage_controller: DamageController = $DamageController
@onready var voting_controller: VotingController = $VotingController


var ai_players: Array[Player] = []
var rooms: Array[Room] = []
var chargers: Array[Charger] = []
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
	instance = self
	if tutorial.visible:
		tutorial.finished.connect(_on_finished)
	else:
		player.speed = 90
		call_deferred("initialize")


func _on_finished() -> void:
	call_deferred("initialize")


func initialize() -> void:
	# main_menu.visible = true
	canvas_layer.follow_viewport_enabled = false

	# init game data
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

	# init game
	player.initialize(player_data)
	ai_player.initialize(ai_player_data)
	rooms_controller.initialize(player, ai_player)
	for room in rooms_controller.rooms:
		if room is Room:
			rooms.append(room)
			receivers.append((room as Room).receiver)
			senders.append((room as Room).sender)
			chargers.append((room as Room).charger)

	terminal_menu.initialize()
	hud.initialize()

	# connect events
	EventBus.terminal_day_ended.connect(_on_day_ended)


func _process(_delta: float) -> void:
	if player.is_died:
		_finish()


func _on_day_ended() -> void:
	if player.is_died:
		_finish()
		return

	var player_room: Room = Data.game.get_by_filter(
		rooms,
		func(item: Room) -> bool: return item.room_index == player.data.room_index)

	if player_room.charger.source <= 0:
		_finish()
		return

	resource_transfer_controller.transfer_resources()

	for item: Player in ai_players:
		assert(item.input_controller is AIController)
		(item.input_controller as AIController).restore_resources()
		(item.input_controller as AIController).share_resources()

	resource_transfer_controller.transfer_resources()
	electricity_controller.decrease_charge()
	damage_controller.damage_machines()

	# show day results
	# wait for player to press next to start day
	# show room effects
	# wait for player to press next to start day

	Data.game.day_number += 1
	EventBus.rooms_updated.emit()

func _finish() -> void:
	Notification.instance.show_warning("Game Over")
	process_mode = PROCESS_MODE_DISABLED
	# game over
	# show results
	pass
