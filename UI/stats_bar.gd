class_name StatsBar
extends HBoxContainer

@onready var coins_value: Label = $StatCoin/CoinsValue
@onready var aura_value: Label = $StatEnergy/EnergyValue
@onready var food_value: Label = $StatFood/FoodValue
@onready var waiting_value: Label = $StatWaiting/WaitingValue

func _ready() -> void:
	Events.food_made.connect(_refresh)
	Events.customer_served.connect(_refresh)
	Events.customer_arrived.connect(_refresh)
	Events.customer_left.connect(_refresh)
	Events.aura_gained.connect(_on_aura_gained)
	_refresh()

func _on_aura_gained(_amount: int, _source: String) -> void:
	_refresh()

func _refresh(_arg = null) -> void:
	coins_value.text = str(GameState.coins)
	aura_value.text = str(GameState.aura)
	food_value.text = str(GameState.food)
	waiting_value.text = str(GameState.customers.size())
