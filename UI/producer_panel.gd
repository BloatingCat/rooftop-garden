# res://ui/ProducerPanel.gd
class_name ProducerPanel
extends PanelContainer

const CARD_SCENE := preload("res://ui/producer_card.tscn")

@onready var card_list: VBoxContainer = %CardList

func _ready() -> void:
	Events.producer_registered.connect(_on_producer_registered)

func _on_producer_registered(producer: Node) -> void:
	var card := CARD_SCENE.instantiate() as ProducerCard
	card_list.add_child(card)
	card.setup(producer)
