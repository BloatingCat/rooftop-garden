class_name UpgradeCard
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel
@onready var buy_button: Button = %BuyButton

var _upgrade: UpgradeData = null

func setup(upgrade: UpgradeData) -> void:
	_upgrade = upgrade
	title_label.text = upgrade.title
	description_label.text = upgrade.description
	_refresh_cost()
	buy_button.pressed.connect(_on_buy_pressed)
	Events.upgrade_completed.connect(_on_upgrade_completed)
	Events.upgrade_failed.connect(_on_upgrade_failed)

func _process(_delta: float) -> void:
	if _upgrade == null:
		return
	_refresh_cost()
	_refresh_affordability()

func _refresh_cost() -> void:
	match _upgrade.cost_currency:
		UpgradeData.CostCurrency.COINS:
			cost_label.text = "%d coins" % _upgrade.cost_coins
		UpgradeData.CostCurrency.AURA:
			cost_label.text = "%d aura" % _upgrade.cost_aura
		UpgradeData.CostCurrency.COINS_AND_AURA:
			cost_label.text = "%d coins + %d aura" % [
				_upgrade.cost_coins,
				_upgrade.cost_aura
			]

func _refresh_affordability() -> void:
	var can_afford := false
	match _upgrade.cost_currency:
		UpgradeData.CostCurrency.COINS:
			can_afford = GameState.coins >= _upgrade.cost_coins
		UpgradeData.CostCurrency.AURA:
			can_afford = GameState.aura >= _upgrade.cost_aura
		UpgradeData.CostCurrency.COINS_AND_AURA:
			can_afford = GameState.coins >= _upgrade.cost_coins \
				and GameState.aura >= _upgrade.cost_aura
	buy_button.disabled = not can_afford

func _on_buy_pressed() -> void:
	Events.upgrade_purchased.emit(_upgrade)

func _on_upgrade_completed(upgrade: UpgradeData) -> void:
	if upgrade.id == _upgrade.id:
		queue_free()

func _on_upgrade_failed(upgrade: UpgradeData, _reason: String) -> void:
	if upgrade.id != _upgrade.id:
		return
	# brief visual shake to signal can't afford
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", position - Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", position, 0.05)
