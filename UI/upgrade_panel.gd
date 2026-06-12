
class_name UpgradePanel
extends PanelContainer

const CARD_SCENE := preload("res://ui/upgrade_card.tscn")

@onready var card_list: VBoxContainer = %CardList

func _ready() -> void:
	Events.upgrade_available.connect(_on_upgrade_available)

func _on_upgrade_available(upgrade: UpgradeData) -> void:
	var card := CARD_SCENE.instantiate() as UpgradeCard
	card_list.add_child(card)
	card.setup(upgrade)
