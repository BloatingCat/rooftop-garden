class_name ServingSystem
extends Node

const BASE_SERVE_TIME := 3.0

var _serving: bool = false
var _serve_accum: float = 0.0
var _current_customer: Dictionary = {}

func _process(delta: float) -> void:
	if not _serving:
		_try_start_serving()
		return
	_serve_accum += delta
	if _serve_accum >= _serve_time():
		_complete_serve()

func _try_start_serving() -> void:
	if GameState.food < 1:
		return
	if GameState.customers.is_empty():
		return
	_current_customer = GameState.customers[0]
	_serving = true
	_serve_accum = 0.0
	Events.serving_started.emit(_current_customer)

func _complete_serve() -> void:
	if not GameState.customers.has(_current_customer):
		_reset()
		return
	var c := _current_customer
	GameState.customers.erase(c)
	if c.has("node") and is_instance_valid(c["node"]):
		c["node"].queue_free()
	GameState.food -= 1
	GameState.coins += GameState.base_sale_price
	Events.customer_served.emit(c)
	_reset()

func _reset() -> void:
	_serving = false
	_serve_accum = 0.0
	_current_customer = {}

func _serve_time() -> float:
	return BASE_SERVE_TIME * GameState.serve_speed_mult
	# later: return BASE_SERVE_TIME * GameState.serve_speed_multiplier
