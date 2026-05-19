# MakeFoodButton.gd
class_name MakeFoodButton
extends VBoxContainer

const FOOD_COST := 2

@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)
	Events.food_made.connect(_refresh)
	Events.customer_served.connect(_refresh)
	_refresh()

func _on_pressed() -> void:
	if GameState.coins < FOOD_COST:
		return
	GameState.coins -= FOOD_COST
	GameState.food += 1
	Events.food_made.emit()

func _refresh(_arg = null) -> void:
	var can_afford := GameState.coins >= FOOD_COST
	button.disabled = not can_afford
	
