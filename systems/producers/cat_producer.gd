class_name CatProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 2
@export var proximity_radius: float = 80.0

var stored_aura: int = 0
var _accum: float = 0.0
var _pool: AuraParticlePool = null

func _ready() -> void:
	await get_tree().process_frame
	_pool = get_tree().get_first_node_in_group("aura_pool")

func _process(delta: float) -> void:
	_accum += delta
	if _accum < tick_interval:
		return
	_accum -= tick_interval
	var nearby_guests := _get_nearby_guests()
	if nearby_guests.is_empty():
		return
	var gained := nearby_guests.size() * aura_per_guest_per_tick
	stored_aura += gained
	Events.aura_gained.emit(gained, "cat")
	_spawn_dots(nearby_guests, get_parent() as Node2D)

func _get_nearby_guests() -> Array:
	var cat := get_parent() as Node2D
	var result := []
	for c in GameState.customers:
		if not c.has("node") or not is_instance_valid(c["node"]):
			continue
		if cat.global_position.distance_to(c["node"].global_position) <= proximity_radius:
			result.append(c)
	return result

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

func _spawn_dots(nearby_guests: Array, cat: Node2D) -> void:
	if _pool == null:
		return
	for c in nearby_guests:
		if not c.has("node") or not is_instance_valid(c["node"]):
			continue
		for i in aura_per_guest_per_tick:
			var p := _pool.get_particle()
			if p == null:
				return
			p.launch_to_cat(c["node"].global_position, cat)
