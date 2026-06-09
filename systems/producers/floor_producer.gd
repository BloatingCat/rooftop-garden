class_name FloorProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 1
@export var floor_y: float = 400.0

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
	var n := GameState.customers.size()
	if n == 0:
		return
	GameState.aura += n * aura_per_guest_per_tick
	Events.aura_gained.emit(n * aura_per_guest_per_tick, "floor")
	_spawn_dots()
	
func _spawn_dots() -> void:
	print("spawning dots, pool: ", _pool)
	if _pool == null:
		return
	for c in GameState.customers:
		if not c.has("node") or not is_instance_valid(c["node"]):
			continue
		for i in aura_per_guest_per_tick:
			var p := _pool.get_particle()
			if p == null:
				return
			p.launch_to_floor(c["node"].global_position, floor_y)
