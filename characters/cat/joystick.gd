class_name Joystick
extends Control

@export var dead_zone: float = 10.0
@export var knob_max_distance: float = 50.0

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Knob

var touch_index: int = -1
var origin: Vector2 = Vector2.ZERO
var output: Vector2 = Vector2.ZERO 

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	## ---- Touch ----
	#if event is InputEventScreenTouch:
		#if event.pressed and touch_index == -1:
			#if _is_inside(event.position):
				#touch_index = event.index
				#origin = event.position  
				#_move_knob(Vector2.ZERO)
		#elif not event.pressed and event.index == touch_index:
			#_release()
#
	#if event is InputEventScreenDrag and event.index == touch_index:
		#var delta = event.position - origin
		#var clamped = delta.limit_length(knob_max_distance)
		#_move_knob(clamped)
		#output = Vector2.ZERO if delta.length() < dead_zone else (clamped / knob_max_distance)

	# ---- Mouse fallback (editor / desktop testing) ----
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and touch_index == -1:
			if _is_inside(event.position):
				touch_index = 0
				# Convert screen origin to LOCAL space
				origin = get_global_transform().affine_inverse() * event.position
				_move_knob(Vector2.ZERO)
				accept_event()
		elif not event.pressed and touch_index == 0:
			_release()
			accept_event()

	if event is InputEventMouseMotion and touch_index == 0:
		# Convert screen position to LOCAL space
		var local_pos = get_global_transform().affine_inverse() * event.position
		var delta = local_pos - origin
		var clamped = delta.limit_length(knob_max_distance)
		_move_knob(clamped)
		output = Vector2.ZERO if delta.length() < dead_zone else (clamped / knob_max_distance)
		accept_event()


func _release():
	touch_index = -1
	output = Vector2.ZERO
	_move_knob(Vector2.ZERO)

func _move_knob(offset: Vector2):
	# base.size / 2 = center of base circle, offset from there
	knob.position = base.position + base.size / 2.0 + offset - knob.size / 2.0

func _is_inside(screen_pos: Vector2) -> bool:
	# Convert screen pos to local, check distance from base center
	var local = get_global_transform().affine_inverse() * screen_pos
	var center = base.position + base.size / 2.0
	return local.distance_to(center) <= base.size.x / 2.0

func get_output() -> Vector2:
	return output
