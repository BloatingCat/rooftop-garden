class_name AuraParticle
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var _active := false
var _target: Node2D = null          # for cat homing — moving target
var _target_pos: Vector2 = Vector2.ZERO  # for floor — fixed destination
var _is_homing := false
var _velocity := Vector2.ZERO
var _seek_speed := 180.0
var _pop_done := false

const POP_OFFSET_RANGE := 12.0
const POP_HEIGHT := 10.0
const POP_DURATION := 0.18
const FLOOR_FALL_SPEED := 140.0

func _ready() -> void:
	print("AuraParticle ready, parent: ", get_parent(), " global_pos: ", global_position)

func _process(delta: float) -> void:
	if not _active:
		#print("particle active, pos: ", global_position, " pop_done: ", _pop_done)
		return
	if not _pop_done:
		return
	if _is_homing:
		_seek(delta)
	else:
		_fall(delta)

func launch_to_floor(from: Vector2, floor_y: float) -> void:
	global_position = from + Vector2(randf_range(-POP_OFFSET_RANGE, POP_OFFSET_RANGE), 0)
	_target_pos = Vector2(global_position.x, floor_y)
	_is_homing = false
	_active = true
	_pop_done = false
	visible = true        # ← the particle node itself
	sprite.visible = true
	_do_pop(Vector2(0, -POP_HEIGHT))

func launch_to_cat(from: Vector2, cat: Node2D) -> void:
	global_position = from + Vector2(randf_range(-POP_OFFSET_RANGE, POP_OFFSET_RANGE), 0)
	_target = cat
	_is_homing = true
	_active = true
	_pop_done = false
	visible = true
	sprite.visible = true
	_do_pop(Vector2(0, -POP_HEIGHT))

func _do_pop(offset: Vector2) -> void:
	var start := global_position
	var tween := create_tween()
	tween.tween_property(self, "global_position", start + offset, POP_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): _pop_done = true)

func _fall(delta: float) -> void:
	global_position.y += FLOOR_FALL_SPEED * delta
	if global_position.y >= _target_pos.y:
		_deactivate()

func _seek(delta: float) -> void:
	if not is_instance_valid(_target):
		_deactivate()
		return
	var dir := (_target.global_position - global_position).normalized()
	_velocity += dir * 400.0 * delta
	_velocity = _velocity.limit_length(_seek_speed)
	global_position += _velocity * delta
	if global_position.distance_to(_target.global_position) < 8.0:
		_deactivate()

func _deactivate() -> void:
	_active = false
	_pop_done = false
	_velocity = Vector2.ZERO
	_target = null
	visible = false       # ← hide the node, not just the sprite
	sprite.visible = false
