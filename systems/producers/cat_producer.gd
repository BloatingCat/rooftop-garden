class_name CatProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 2
@export var proximity_radius: float = 80.0
@export var display_name: String = "Black Cat"

var stored_aura: int = 0
var cumulative_aura: int = 0
var guests_in_range: int = 0
var _accum: float = 0.0
var _pool: AuraParticlePool = null

func _ready() -> void:
	await get_tree().process_frame
	_pool = get_tree().get_first_node_in_group("aura_pool")
	Events.producer_registered.emit(self)

func _process(delta: float) -> void:
	_accum += delta
	if _accum < tick_interval:
		return
	_accum -= tick_interval
	var nearby := _get_nearby_guests()
	guests_in_range = nearby.size()
	if guests_in_range == 0:
		return
	var gained := guests_in_range * aura_per_guest_per_tick
	stored_aura += gained
	GameState.aura += gained
	cumulative_aura += gained
	Events.aura_gained.emit(gained, "cat")
	_spawn_dots(nearby)

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

func _spawn_dots(nearby_guests: Array) -> void:
	if _pool == null:
		return
	var cat := get_parent() as Node2D
	for c in nearby_guests:
		if not c.has("node") or not is_instance_valid(c["node"]):
			continue
		for i in aura_per_guest_per_tick:
			var p := _pool.get_particle()
			if p == null:
				return
			p.launch_to_cat(c["node"].global_position, cat)
