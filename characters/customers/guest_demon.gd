# res://guests/GuestDemon.gd
class_name GuestDemon
extends CharacterBody2D

@onready var body: Sprite2D = $Body
@onready var tail: Sprite2D = $Tail
@onready var top_feature: Sprite2D = $TopFeatures
@onready var eyes: Sprite2D = $Eyes
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

const EYES: Array[String] = [
	"res://assets/npc/small_eyes.png",
	"res://assets/npc/large_eyes.png",
]

const TOP_FEATURES: Array[String] = [
	"res://assets/npc/small_horns.png",
	"res://assets/npc/large_horns.png",
	"res://assets/npc/ears.png",
]

const EYE_COLORS: Array[Color] = [
	Color(0.9, 0.2, 0.2),    # red
	Color(0.6, 0.2, 0.9),    # purple
	Color(0.2, 0.8, 0.6),    # teal
	Color(0.9, 0.6, 0.1),    # amber
]

const BODY_TINTS: Array[Color] = [
	Color(0.85, 0.85, 0.85), # ashen
	Color(0.6, 0.5, 0.75),   # violet
	Color(0.4, 0.4, 0.4),    # dark grey
	Color(0.7, 0.4, 0.35),   # rust
]

const MOVE_SPEED := 60.0
const WANDER_RADIUS := 120.0
const WANDER_WAIT_MIN := 1.5
const WANDER_WAIT_MAX := 4.0
const ARRIVE_DISTANCE := 12.0

var _nav_ready := false
var _waiting := false
var _wait_timer := 0.0
var _home_position := Vector2.ZERO

func _ready() -> void:
	await get_tree().process_frame
	_nav_ready = true
	_home_position = global_position
	_pick_new_destination()

func _physics_process(delta: float) -> void:
	if not _nav_ready:
		return
	if _waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_waiting = false
			_pick_new_destination()
		return
	if nav_agent.is_navigation_finished():
		_start_waiting()
		return
	var next := nav_agent.get_next_path_position()
	var direction := (next - global_position).normalized()
	velocity = direction * MOVE_SPEED
	move_and_slide()
	
func _pick_new_destination() -> void:
	print("picking destination, home: ", _home_position)
	# wander within radius of where they spawned
	var angle := randf() * TAU
	var dist := randf_range(20.0, WANDER_RADIUS)
	var target := _home_position + Vector2(cos(angle), sin(angle)) * dist
	# snap to navmesh
	var map := get_world_2d().navigation_map
	var valid := NavigationServer2D.map_get_closest_point(map, target)
	print("target: ", target, " snapped: ", valid)
	nav_agent.target_position = valid

func setup(customer_data: Dictionary) -> void:
	randomize_appearance()
	set_meta("customer_id", customer_data["id"])
	# record spawn position as home — wander radius is relative to this

func _start_waiting() -> void:
	_waiting = true
	_wait_timer = randf_range(WANDER_WAIT_MIN, WANDER_WAIT_MAX)
	velocity = Vector2.ZERO

func randomize_appearance() -> void:
	# body tint
	body.modulate = BODY_TINTS[randi() % BODY_TINTS.size()]

	# tail — 50% chance
	tail.visible = randf() > 0.5

	# top feature — horns or ears
	var feature_path := TOP_FEATURES[randi() % TOP_FEATURES.size()]
	top_feature.texture = load(feature_path)

	# eyes — shape random, color random
	var eye_path := EYES[randi() % EYES.size()]
	eyes.texture = load(eye_path)
	eyes.modulate = EYE_COLORS[randi() % EYE_COLORS.size()]
