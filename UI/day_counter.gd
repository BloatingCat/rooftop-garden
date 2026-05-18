class_name DayCounter
extends PanelContainer

@onready var clock_label: Label = $MarginContainer/VBoxContainer/ClockLabel
@onready var day_label: Label = $MarginContainer/VBoxContainer/DayLabel
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

const START_HOUR := 18       
const SPAN_HOURS := 6.0

func _ready() -> void:
	#Events.day_started.connect(_on_day_started)
	pass

func _process(_delta: float) -> void:
	_update_display()

func 	_update_display() -> void:
	var t: float = clampf(GameState.day_elapsed / GameState.DAY_DURATION_REAL, 0.0, 1.0)
	var total_minutes: float = t * SPAN_HOURS * 60.0
	var hour: int = START_HOUR + int(total_minutes / 60.0)
	var minute: int = int(total_minutes) % 60

	var suffix := "PM"
	if hour >= 24:
		hour -= 24
		suffix = "AM"

	var display_hour: int = hour
	if display_hour == 0:
		display_hour = 12
	elif display_hour > 12:
		display_hour -= 12

	clock_label.text = "%d:%02d %s" % [display_hour, minute, suffix]
	progress_bar.value = t * 100.0


func _on_day_started(day: int) -> void:
	day_label.text = "Day %d" % day
