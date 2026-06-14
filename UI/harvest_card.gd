class_name HarvestCard
extends CanvasLayer

const BODY_SLOT_SCENE := preload("res://ui/body_slot.tscn")

@onready var aura_value: Label = %AuraValue
@onready var slot_row: HBoxContainer = %SlotRow
@onready var harvest_progress: ProgressBar = %HarvestProgress
@onready var close_button: Button = %CloseButton
@onready var tooltip_label: Label = %TooltipLabel

const SLOT_ICONS: Array[String] = [
	"res://assets/cat/card_head.png",
	"res://assets/cat/card_belly.png",
	"res://assets/cat/card_balls.png",
]

var _frozen_aura: int = 0
var _slots: Array[BodySlot] = []
var _clicked_count: int = 0
var _cat_producer: CatProducer = null

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)
	Events.harvest_slot_clicked.connect(_on_slot_clicked)
	tooltip_label.text = "Pet each part to harvest stored aura"

func open(cat_producer: CatProducer) -> void:
	_cat_producer = cat_producer
	_frozen_aura = cat_producer.stored_aura
	_clicked_count = 0
	aura_value.text = str(_frozen_aura)
	_build_slots()
	harvest_progress.max_value = _slots.size()
	harvest_progress.value = 0
	visible = true

func _build_slots() -> void:
	# clear previous
	for child in slot_row.get_children():
		child.queue_free()
	_slots.clear()
	for i in SLOT_ICONS.size():
		var slot := BODY_SLOT_SCENE.instantiate() as BodySlot
		slot_row.add_child(slot)
		slot.setup(i, load(SLOT_ICONS[i]))
		_slots.append(slot)

func _on_slot_clicked(_index: int) -> void:
	_clicked_count += 1
	harvest_progress.value = _clicked_count
	if _clicked_count >= _slots.size():
		_complete_harvest()

func _complete_harvest() -> void:
	aura_value.text = "0"
	await get_tree().create_timer(0.5).timeout
	_cat_producer.harvest()
	Events.harvest_completed.emit(_frozen_aura)
	_close_and_release()

func _on_close() -> void:
	Events.harvest_cancelled.emit()
	_close_and_release()

func _close_and_release() -> void:
	# reset all slots
	for slot in _slots:
		slot.reset()
	_clicked_count = 0
	visible = false
	Events.cat_released_from_platform.emit()
