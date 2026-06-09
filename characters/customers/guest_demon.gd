# res://guests/GuestDemon.gd
class_name GuestDemon
extends CharacterBody2D

@onready var body: Sprite2D = $Body
@onready var tail: Sprite2D = $Tail
@onready var top_feature: Sprite2D = $TopFeatures
@onready var eyes: Sprite2D = $Eyes
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var data: GuestData
var _nav_ready := false
var _waiting := false
var _wait_timer := 0.0
var _home_position := Vector2.ZERO
var _aura_accum := 0.0
var _customer_id: int = -1

#const EYES: Array[String] = [
	#"res://assets/npc/small_eyes.png",
	#"res://assets/npc/large_eyes.png",
#]
#
#const TOP_FEATURES: Array[String] = [
	#"res://assets/npc/small_horns.png",
	#"res://assets/npc/large_horns.png",
	#"res://assets/npc/ears.png",
#]
#
#const EYE_COLORS: Array[Color] = [
	#Color(0.9, 0.2, 0.2),    # red
	#Color(0.6, 0.2, 0.9),    # purple
	#Color(0.2, 0.8, 0.6),    # teal
	#Color(0.9, 0.6, 0.1),    # amber
#]
#
#const BODY_TINTS: Array[Color] = [
	#Color(0.85, 0.85, 0.85), # ashen
	#Color(0.6, 0.5, 0.75),   # violet
	#Color(0.4, 0.4, 0.4),    # dark grey
	#Color(0.7, 0.4, 0.35),   # rust
#]
#
#const MOVE_SPEED := 60.0
#const WANDER_RADIUS := 120.0
#const WANDER_WAIT_MIN := 1.5
#const WANDER_WAIT_MAX := 4.0
#const ARRIVE_DISTANCE := 12.0
#
#var _nav_ready := false
#var _waiting := false
#var _wait_timer := 0.0
#var _home_position := Vector2.ZERO

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
	velocity = direction * data.move_speed
	move_and_slide()
	
func _pick_new_destination() -> void:
	var angle := randf() * TAU
	var dist := randf_range(20.0, data.wander_radius)
	var target := _home_position + Vector2(cos(angle), sin(angle)) * dist
	var map := get_world_2d().navigation_map
	var valid := NavigationServer2D.map_get_closest_point(map, target)
	nav_agent.target_position = valid

func setup(customer_data: Dictionary, guest_data: GuestData) -> void:
	data = guest_data
	_customer_id = customer_data["id"]
	set_meta("customer_id", _customer_id)
	randomize_appearance()

func _start_waiting() -> void:
	_waiting = true
	_wait_timer = randf_range(data.wander_wait_min, data.wander_wait_max)
	velocity = Vector2.ZERO

func randomize_appearance() -> void:
	if data.body_texture:
		body.texture = data.body_texture
	if data.tail_texture:
		tail.texture = data.tail_texture
		tail.visible = randf() > 0.5
	if data.top_textures.size() > 0:
		top_feature.texture = data.top_textures[randi() % data.top_textures.size()]
	if data.eye_textures.size() > 0:
		eyes.texture = data.eye_textures[randi() % data.eye_textures.size()]
	if data.body_tints.size() > 0:
		body.modulate = data.body_tints[randi() % data.body_tints.size()]
	if data.eye_colors.size() > 0:
		eyes.modulate = data.eye_colors[randi() % data.eye_colors.size()]
