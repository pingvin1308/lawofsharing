class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated

var interactor: CharacterBody2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		interactor = body
		interactable_activated.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		interactor = null
		interactable_deactivated.emit()
