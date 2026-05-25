extends Camera2D

var dragging = false

# Zoom settings
var target_zoom = 1.0
const MIN_ZOOM = 0.3 # further out
const MAX_ZOOM = 4.0 # further in
const ZOOM_SPEED = 0.15

func _input(event):
	# 1. HANDLE DRAGGING
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom

	# 2. HANDLE ZOOMING toward mouse pointer
	if event is InputEventMouseButton:
		var zoom_dir = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_dir = 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_dir = -1

		if zoom_dir != 0:
			var old_zoom = target_zoom
			target_zoom = clamp(target_zoom + zoom_dir * ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)

			# World position under the mouse before zoom
			var mouse_pos = get_local_mouse_position()
			# Shift camera so that world point stays fixed under cursor
			position -= mouse_pos * (1.0 - target_zoom / old_zoom)
			# or 
			# position += mouse_pos * (target_zoom / old_zoom - 1.0)

func _process(delta):
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 10 * delta)
