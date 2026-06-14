class_name BodySlot
extends TextureButton

@onready var grey_overlay: ColorRect = $GreyOverlay

var slot_index: int = -1
var is_clicked: bool = false

func setup(index: int, icon: Texture2D) -> void:
	slot_index = index
	texture_normal = icon
	grey_overlay.visible = false
	is_clicked = false
	pressed.connect(_on_pressed)

func reset() -> void:
	grey_overlay.visible = false
	is_clicked = false
	disabled = false

func _on_pressed() -> void:
	if is_clicked:
		return
	is_clicked = true
	grey_overlay.visible = true
	disabled = true
	Events.harvest_slot_clicked.emit(slot_index)
