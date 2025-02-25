class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated

var interactor: Player

@export var action_name: String
@export var is_breakable: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interactor = body
		interactable_activated.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		interactor = null
		interactable_deactivated.emit()
