class_name FloorProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 1

var _accum: float = 0.0

func _process(delta: float) -> void:
	_accum += delta
	if _accum < tick_interval:
		return
	_accum -= tick_interval
	var n := GameState.customers.size()
	if n == 0:
		return
	var gained := n * aura_per_guest_per_tick
	GameState.aura += gained
	Events.aura_gained.emit(gained, "floor")
