class_name Cat
extends CharacterBody2D

@export var data: CatData

@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: CatStateMachine = $CatStateMachine
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var _nav_ready := false

var joystick: Joystick = null

var _velocity: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _facing: String = "down"  

const DIR_MAP = {
	"down":       Vector2(0,  1),
	"up":         Vector2(0, -1),
	"left":       Vector2(-1, 0),
	"right":      Vector2(1,  0),
	"down_right": Vector2(1,  1),
	"down_left":  Vector2(-1, 1),
	"up_right":   Vector2(1, -1),
	"up_left":    Vector2(-1,-1),
}

func _ready():
	var map = get_world_2d().navigation_map
	NavigationServer2D.map_changed.connect(_on_map_ready)

func _on_map_ready(map_rid: RID):
	var my_map = get_world_2d().navigation_map
	if map_rid == my_map:
		_nav_ready = true
		NavigationServer2D.map_changed.disconnect(_on_map_ready)

func _physics_process(delta: float):
	_read_input()
	_apply_movement(delta)
	_update_facing()
	#_update_animation()
	move_and_slide()

# ── Input ────────────────────────────────────────────────────────────────────

func _read_input():
	# Joystick (mobile)
	if joystick:
		_direction = joystick.get_output()
		return

	# Keyboard fallback (testing in editor)
	_direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up",   "ui_down")
	).normalized()

# ── Movement ─────────────────────────────────────────────────────────────────

func _apply_movement(delta: float):
	if _direction != Vector2.ZERO:
		_velocity = _velocity.move_toward(
			_direction * data.move_speed,
			data.acceleration * delta
		)
		state_machine.transition(CatStateMachine.State.WALK)
	else:
		_velocity = _velocity.move_toward(Vector2.ZERO, data.friction * delta)
		state_machine.transition(CatStateMachine.State.IDLE)

	velocity = _velocity
	move_and_slide()

	# Only snap after navmesh is ready
	if not _nav_ready:
		return

	var map = get_world_2d().navigation_map
	var closest = NavigationServer2D.map_get_closest_point(map, global_position)
	global_position = closest

# ── Facing ───────────────────────────────────────────────────────────────────

func _update_facing():
	if _direction == Vector2.ZERO:
		return

	# For now: 4-dir. Swap to 8-dir when spritesheet is ready.
	if abs(_direction.x) > abs(_direction.y):
		_facing = "right" if _direction.x > 0 else "left"
	else:
		_facing = "down" if _direction.y > 0 else "up"
		
