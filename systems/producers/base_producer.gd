class_name BaseProducer
extends Node

@export var tick_interval: float = 5.0
@export var amount_per_tick: int = 1
@export var source_name: String = "unknown"

var _accum: float = 0.0

func _process(delta: float) -> void:
	_accum += delta
	if _accum >= tick_interval:
		_accum -= tick_interval
		var amount := _get_amount()
		if amount > 0:
			_on_produce(amount)

func _get_amount() -> int:
	return amount_per_tick

func _on_produce(amount: int) -> void:
	GameState.aura += amount
	Events.aura_gained.emit(amount, source_name)
