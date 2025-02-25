class_name Game
extends Node2D

@onready var player: Player = $Player
@onready var ai_player: Player = $AIPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var rooms_controller: RoomsController = $RoomsController
@onready var terminal_menu: TerminalMenu = $CanvasLayer/TerminalMenu
@onready var hud: HUD = $CanvasLayer/HUD
@onready var voting_controller: VotingController = $VotingController
var days_passed: int = 0

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
	var player_data := Data.PlayerData.new(0)

	var rooms: Array[Data.RoomData] = []
	var machines: Array[Data.MachineData] = []
	var receivers: Array[Data.ReceiverData] = []

	for index in Data.ResourceType.keys().size():
		#var resource_type = Data.ResourceType.get(index)
		var room_data := Data.RoomData.new(index, index)
		rooms.append(room_data)

		for resource_type: Data.ResourceType in Data.ResourceType.values():
			var machine := Data.MachineData.new(index, resource_type)
			machines.append(machine)

		var receiver: Data.ReceiverData = Data.ReceiverData.new(index)
		receivers.append(receiver)

	var ai_player_data := Data.PlayerData.new(0, true)
	var ai_players: Array[Data.PlayerData] = [ai_player_data]

	Data.game = Data.GameData.new(
		rooms,
		player_data,
		machines,
		ai_players)
	Data.game.receivers = receivers

	player.initialize(player_data)
	ai_player.initialize(ai_player_data)
	rooms_controller.initialize(player, ai_player)
	#voting_controller.initialize(
		#rooms_controller.player_room_data,
		#rooms_controller.rooms)
	terminal_menu.initialize()
	hud.initialize()


func _process(delta: float) -> void:
	if player.is_died:
		print("Game over!")


func _on_game_end_day() -> void:
	# check if game finished
	# check goals
	# transfer_resources()
	# damage_machines()
	# exchange_rooms()
	pass
