class_name Platform
extends Area2D

@onready var cat_lock_point: Marker2D = $CatLockPoint

var _cat: Cat = null
var _cat_producer: CatProducer = null
var _harvest_card: HarvestCard = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	#print("Pedestal ready, monitoring: ", monitoring)
	Events.cat_released_from_platform.connect(_on_cat_released)
	# find harvest card in scene
	await get_tree().process_frame
	_harvest_card = get_tree().get_first_node_in_group("harvest_card")

func _on_body_entered(body: Node2D) -> void:
	#print("body entered pedestal: ", body.name)
	if body is not Cat:
		return
	if _cat != null:
		return
	_cat = body as Cat
	_cat_producer = _cat.get_node("CatProducer") as CatProducer
	_lock_cat()

func _lock_cat() -> void:
	# disable joystick input and navigation
	print("locking cat, cat: ", _cat)
	print("cat_producer: ", _cat_producer)
	print("harvest_card: ", _harvest_card)
	_cat.set_process(false)
	_cat.set_physics_process(false)
	_cat.velocity = Vector2.ZERO
	_cat.global_position = cat_lock_point.global_position
	# pause aura production
	_cat_producer.locked = true
	Events.cat_locked_to_platform.emit()
	# open harvest card
	#if _harvest_card:
		#_harvest_card.open(_cat_producer)
	if _harvest_card:
		print("opening harvest card")
		_harvest_card.open(_cat_producer)
	else:
		print("harvest card is null")

func _on_cat_released() -> void:
	if _cat == null:
		return
	_cat.set_process(true)
	_cat.set_physics_process(true)
	_cat_producer.locked = false
	_cat = null
	_cat_producer = null
