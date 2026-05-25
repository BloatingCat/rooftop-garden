class_name UpgradeSystem
extends Node

@export var upgrades: Array[UpgradeData] = []

var _notified: Array[String] = []

func _process(_delta: float) -> void:
	for upgrade in upgrades:
		if upgrade.id in _notified:
			continue
		if upgrade.id in GameState.purchased_upgrades:
			continue
		if GameState.coins >= upgrade.unlock_at_coins:
			_notified.append(upgrade.id)
			Events.upgrade_available.emit(upgrade)

func _ready() -> void:
	Events.upgrade_purchased.connect(_on_purchased)

func _on_purchased(upgrade: UpgradeData) -> void:
	if GameState.coins < upgrade.cost:
		return
	if upgrade.id in GameState.purchased_upgrades:
		return
	GameState.coins -= upgrade.cost
	GameState.purchased_upgrades.append(upgrade.id)
	_apply(upgrade)
	Events.food_made.emit()  # nudge StatsBar to refresh coins

func _apply(upgrade: UpgradeData) -> void:
	match upgrade.id:
		"dish_1":  GameState.aura_multiplier = 2
		"extra_queue":    GameState.serve_slots = 2
		"serve_speed":    GameState.serve_speed_mult = 0.6
