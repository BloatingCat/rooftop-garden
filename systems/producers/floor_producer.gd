class_name FloorProducer
extends Node

@export var tick_interval: float = 5.0
@export var aura_per_guest_per_tick: int = 1
@export var floor_y: float = 400.0
@export var display_name: String = "Rooftop Floor"

var cumulative_aura: int = 0
var guests_present: int = 0
var _accum: float = 0.0
var _pool: AuraParticlePool = null

func _ready() -> void:
	await get_tree().process_frame
	_pool = get_tree().get_first_node_in_group("aura_pool")
	Events.producer_registered.emit(self)

func _process(delta: float) -> void:
	guests_present = GameState.customers.size()
	_accum += delta
	if _accum < tick_interval:
		return
	_accum -= tick_interval
	if guests_present == 0:
		return
	var gained := guests_present * aura_per_guest_per_tick
	GameState.aura += gained
	cumulative_aura += gained
	Events.aura_gained.emit(gained, "floor")
	_spawn_dots()
	
func _spawn_dots() -> void:
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
