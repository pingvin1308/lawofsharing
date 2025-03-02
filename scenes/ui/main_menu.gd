class_name MainMenu
extends Control

@onready var start_game: Button = $VBoxContainer/StartGame
@onready var options: Button = $VBoxContainer/Options
@onready var exit: Button = $VBoxContainer/Exit



func _ready() -> void:
    start_game.pressed.connect(_on_start_game_pressed)
    options.pressed.connect(_on_options_pressed)
    exit.pressed.connect(_on_exit_pressed)


func _on_start_game_pressed() -> void:
    visible = false
    pass


func _on_options_pressed() -> void:
    pass


func _on_exit_pressed() -> void:
    get_tree().quit()