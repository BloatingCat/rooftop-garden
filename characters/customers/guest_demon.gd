# res://guests/GuestDemon.gd
class_name GuestDemon
extends Node2D

@onready var body: Sprite2D = $Body
@onready var tail: Sprite2D = $Tail
@onready var top_feature: Sprite2D = $TopFeatures
@onready var eyes: Sprite2D = $Eyes

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

func setup(customer_data: Dictionary) -> void:
	randomize_appearance()
	# store reference for later use (serving, aura, etc.)
	set_meta("customer_id", customer_data["id"])
