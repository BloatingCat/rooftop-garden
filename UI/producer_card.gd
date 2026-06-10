# res://ui/ProducerCard.gd
class_name ProducerCard
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var rate_label: Label = %RateLabel
@onready var guests_label: Label = %GuestsLabel
@onready var cumulative_label: Label = %CumulativeLabel

var _producer: Node = null

func setup(producer: Node) -> void:
	_producer = producer

func _process(_delta: float) -> void:
	if _producer == null or not is_instance_valid(_producer):
		return
	name_label.text = _producer.display_name
	rate_label.text = "%d aura / guest / tick  ·  every %.1fs" % [
		_producer.aura_per_guest_per_tick,
		_producer.tick_interval
	]
	# cat uses guests_in_range, floor uses guests_present
	var guests: int = 0
	if _producer.get("guests_in_range") != null:
		guests = _producer.guests_in_range
	elif _producer.get("guests_present") != null:
		guests = _producer.guests_present
	guests_label.text = "guests: %d" % guests
	cumulative_label.text = "absorbed: %d aura" % _producer.cumulative_aura
