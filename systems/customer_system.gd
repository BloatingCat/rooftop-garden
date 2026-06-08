# res://systems/CustomerSystem.gd
class_name CustomerSystem
extends Node

const PATIENCE_SEC := 12.0
const ENERGY_TICK_SEC := 2.0
const BASE_SPAWN_SEC := 8.0
const MAX_CUSTOMERS := 5

const GUEST_SCENE := preload("res://characters/customers/guest_demon.tscn")
@export var guest_anchor: Node2D

var _spawn_accum := 0.0
var _aura_accum := 0.0

func _process(delta: float) -> void:
	if GameState.day_elapsed >= GameState.DAY_DURATION_REAL:
		return
	_tick_spawn(delta)
	_tick_patience(delta)
	_tick_aura(delta)

func _tick_spawn(delta: float) -> void:
	var interval := maxf(2.5, BASE_SPAWN_SEC - GameState.aura * 0.04)
	_spawn_accum += delta
	if _spawn_accum >= interval:
		_spawn_accum -= interval
		_try_spawn()

func _try_spawn() -> void:
	if GameState.customers.size() >= MAX_CUSTOMERS:
		return
	var c := {
		"id": GameState.next_id,
		"name": _rand_name(),
		"patience_left": PATIENCE_SEC,
		"aura_leaked": 0,
	}
	GameState.next_id += 1
	GameState.customers.append(c)

	var guest := GUEST_SCENE.instantiate() as GuestDemon
	guest_anchor.add_child(guest)
	guest.setup(c)
	c["node"] = guest   # store reference on the data dict
	guest.position = _rand_spawn_position()
		   

	Events.customer_arrived.emit(c)

func _rand_spawn_position() -> Vector2:
	# these should match your visible rooftop floor area in world coords
	var world_pos := Vector2(
		randf_range(200.0, 600.0),
		randf_range(300.0, 450.0)
	)
	return guest_anchor.to_local(world_pos)

func _tick_patience(delta: float) -> void:
	var to_remove := []
	for c in GameState.customers:
		c["patience_left"] -= delta
		if c["patience_left"] <= 0.0:
			to_remove.append(c)
	for c in to_remove:
		_remove_customer(c)
		Events.customer_left.emit(c)

func _tick_aura(delta: float) -> void:
	_aura_accum += delta
	if _aura_accum < ENERGY_TICK_SEC:
		return
	_aura_accum -= ENERGY_TICK_SEC
	var n := GameState.customers.size()
	if n == 0:
		return
	for c in GameState.customers:
		c["aura_leaked"] += 1
	GameState.aura += n
	GameState.day_aura += n
	Events.aura_gained.emit(n, "ambient")

func _rand_name() -> String:
	var names := ["Linh","Minh","Hoa","Nam","Thu","Bao","Mai","Tuan",
				  "Lan","Duc","Anh","Khoa","Vex","Morvyn","Sha","Nul","Drev"]
	return names[randi() % names.size()]

func _remove_customer(c: Dictionary) -> void:
	GameState.customers.erase(c)
	if c.has("node") and is_instance_valid(c["node"]):
		c["node"].queue_free()
