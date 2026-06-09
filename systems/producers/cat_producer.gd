class_name CatProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 2
@export var proximity_radius: float = 80.0

var stored_aura: int = 0
var _accum: float = 0.0

func _process(delta: float) -> void:
	_accum += delta
	if _accum < tick_interval:
		return
	_accum -= tick_interval
	var nearby := _count_nearby_guests()
	if nearby == 0:
		return
	var gained := nearby * aura_per_guest_per_tick
	stored_aura += gained
	GameState.aura += gained			# add cat value to total aura
	Events.aura_gained.emit(gained, "cat")

func harvest() -> void:
	if stored_aura == 0:
		return
	GameState.aura += stored_aura
	Events.aura_gained.emit(stored_aura, "cat_harvest")
	stored_aura = 0

func _count_nearby_guests() -> int:
	var cat := get_parent() as Node2D
	var count := 0
	for c in GameState.customers:
		if not c.has("node") or not is_instance_valid(c["node"]):
			continue
		if cat.global_position.distance_to(c["node"].global_position) <= proximity_radius:
			count += 1
	return count
