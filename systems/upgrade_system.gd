class_name UpgradeSystem
extends Node

@export var upgrades: Array[UpgradeData] = []
@export var building_anchor: Node2D

var _notified: Array[String] = []

func _ready() -> void:
	Events.upgrade_purchased.connect(_on_purchased)

func _process(_delta: float) -> void:
	for upgrade in upgrades:
		if upgrade.id in _notified:
			continue
		if upgrade.id in GameState.purchased_upgrades:
			continue
		if _threshold_met(upgrade):
			_notified.append(upgrade.id)
			Events.upgrade_available.emit(upgrade)

func _threshold_met(upgrade: UpgradeData) -> bool:
	match upgrade.cost_currency:
		UpgradeData.CostCurrency.COINS:
			return GameState.coins >= upgrade.unlock_coins
		UpgradeData.CostCurrency.AURA:
			return GameState.aura >= upgrade.unlock_aura
		UpgradeData.CostCurrency.COINS_AND_AURA:
			return GameState.coins >= upgrade.unlock_coins \
				and GameState.aura >= upgrade.unlock_aura
	return false

func _can_afford(upgrade: UpgradeData) -> bool:
	match upgrade.cost_currency:
		UpgradeData.CostCurrency.COINS:
			return GameState.coins >= upgrade.cost_coins
		UpgradeData.CostCurrency.AURA:
			return GameState.aura >= upgrade.cost_aura
		UpgradeData.CostCurrency.COINS_AND_AURA:
			return GameState.coins >= upgrade.cost_coins \
				and GameState.aura >= upgrade.cost_aura
	return false

func _on_purchased(upgrade: UpgradeData) -> void:
	if upgrade.id in GameState.purchased_upgrades:
		return
	if not _can_afford(upgrade):
		Events.upgrade_failed.emit(upgrade, "not_enough")
		return
	_deduct_cost(upgrade)
	GameState.purchased_upgrades.append(upgrade.id)
	_apply(upgrade)
	Events.upgrade_completed.emit(upgrade)

func _deduct_cost(upgrade: UpgradeData) -> void:
	match upgrade.cost_currency:
		UpgradeData.CostCurrency.COINS:
			GameState.coins -= upgrade.cost_coins
		UpgradeData.CostCurrency.AURA:
			GameState.aura -= upgrade.cost_aura
		UpgradeData.CostCurrency.COINS_AND_AURA:
			GameState.coins -= upgrade.cost_coins
			GameState.aura -= upgrade.cost_aura

func _apply(upgrade: UpgradeData) -> void:
	match upgrade.upgrade_type:
		UpgradeData.UpgradeType.STAT:
			_apply_stat(upgrade)
		UpgradeData.UpgradeType.BUILDING:
			_apply_building(upgrade)

func _apply_stat(upgrade: UpgradeData) -> void:
	match upgrade.id:
		"better_stew":
			GameState.base_sale_price += 2
		"faster_hands":
			GameState.serve_speed_mult *= 0.6
		"second_server":
			GameState.serve_slots += 1
		"cozy_seating":
			# notify CustomerSystem to update patience for future spawns
			GameState.guest_patience_bonus += 8.0
		"cat_affinity":
			var cat_producer := get_tree().get_first_node_in_group("cat_producer") as CatProducer
			if cat_producer:
				cat_producer.proximity_radius += 40.0
		"dark_appetite":
			var floor_producer := get_tree().get_first_node_in_group("floor_producer") as FloorProducer
			if floor_producer:
				floor_producer.aura_per_guest_per_tick += 1
		"cursed_ingredients":
			GameState.guest_aura_bonus += 1

func _apply_building(upgrade: UpgradeData) -> void:
	if upgrade.building_scene == null:
		push_error("UpgradeSystem: building_scene is null for " + upgrade.id)
		return
	var building := upgrade.building_scene.instantiate()
	building_anchor.add_child(building)
