class_name AuraCounter
extends PanelContainer

@onready var floor_value: Label = %FloorValue
@onready var cat_value: Label = %CatValue

var _floor_total: int = 0
var _cat_total: int = 0

func _ready() -> void:
	Events.aura_gained.connect(_on_aura_gained)

func _on_aura_gained(amount: int, source: String) -> void:
	match source:
		"floor":
			_floor_total += amount
			floor_value.text = str(_floor_total)
		"cat":
			_cat_total += amount
			cat_value.text = str(_cat_total)
