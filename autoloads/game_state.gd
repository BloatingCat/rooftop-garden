extends Node

# GameState.gd (AutoLoad)
const DAY_DURATION_REAL := 60.0      # real seconds per day
const DAY_START_HOUR := 18           # 6 PM
const DAY_END_HOUR := 24             # midnight (0)
const DAY_SPAN_HOURS := 6.0          # hours displayed

var day: int = 1
var day_elapsed: float = 0.0
var day_aura: int = 0         # 0.0 → DAY_DURATION_REAL

var coins: int = 50
var aura: int = 0
var food: int = 0
var customers: Array = [] 

var next_id: int = 1

var total_aura_earned: int = 0   # lifetime, never spent
var guest_aura_bonus: int = 0
var serve_speed_mult: float = 1.0
var serve_slots: int = 1
var base_sale_price: int = 7
var purchased_upgrades: Array[String] = []

var guest_patience_bonus: float = 0.0

const PATIENCE_SEC: float = 12.0

func _process(delta: float) -> void:
	day_elapsed += delta
	if day_elapsed >= DAY_DURATION_REAL:
		day_elapsed -= DAY_DURATION_REAL
		_end_day()

func _end_day() -> void:
	Events.day_ended.emit(day, day_aura)
	day += 1
	day_aura = 0
	Events.day_started.emit(day)

func get_display_time() -> Dictionary:
	var t := day_elapsed / DAY_DURATION_REAL          # 0.0–1.0
	var total_minutes := t * DAY_SPAN_HOURS * 60.0    # 0–360
	var hour := DAY_START_HOUR + int(total_minutes / 60)
	var minute := int(total_minutes) % 60
	if hour >= 24:
		hour -= 24
	return { "hour": hour, "minute": minute }
	
#func remove_customer(c: Dictionary) -> void:
	#customers.erase(c)
	#if c.has("node") and is_instance_valid(c["node"]):
		#c["node"].queue_free()
