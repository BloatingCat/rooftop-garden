class_name LogPanel
extends PanelContainer

@onready var log_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/LogList
@onready var scroll: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer

const MAX_ENTRIES := 40

enum LogType { SYSTEM, ARRIVAL, SALE, LEAVE, AURA, DAY }

func _ready() -> void:
	#print_tree_pretty()
	print("LogPanel size: ", size, " visible: ", visible, " position: ", position)
	#print("LogPanel ready, log_list: ", log_list, " scroll: ", scroll)
	Events.customer_arrived.connect(_on_arrived)
	Events.customer_served.connect(_on_served)
	Events.customer_left.connect(_on_left)
	Events.aura_gained.connect(_on_aura)
	Events.day_ended.connect(_on_day_ended)
	Events.day_started.connect(_on_day_started)
	Events.food_made.connect(_on_food_made)
	_add_entry("The rooftop garden opens. Dark beings will come.", LogType.DAY)

func _on_arrived(c: Dictionary) -> void:
	print("someone arrived")
	_add_entry("%s drifts onto the rooftop." % c["name"], LogType.ARRIVAL)

func _on_served(c: Dictionary) -> void:
	_add_entry("%s takes food and leaves. +7 coins. (%d aura left behind)" % [c["name"], c["aura_leaked"]], LogType.SALE)

func _on_left(c: Dictionary) -> void:
	print("someone left")
	_add_entry("%s fades away — patience gone. (%d aura stained the floor)" % [c["name"], c["aura_leaked"]], LogType.LEAVE)

func _on_aura(amount: int, _source: String) -> void:
	_add_entry("Dark energy seeps in. +%d aura (%d beings present)." % [amount, GameState.customers.size()], LogType.AURA)

func _on_day_ended(day: int, aura_this_day: int) -> void:
	_add_entry("━  Day %d ends. Garden absorbed %d dark aura this cycle.  ━" % [day, aura_this_day], LogType.DAY)

func _on_day_started(day: int) -> void:
	_add_entry("Day %d begins. The garden stirs." % day, LogType.DAY)

func _on_food_made(_arg = null) -> void:
	_add_entry("Food prepared. −2 coins.", LogType.SYSTEM)

func _add_entry(text: String, type: LogType) -> void:
	#print("_add_entry called: ", text)
	var label := Label.new()
	label.text = "[%s]  %s" % [_timestamp(), text]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", _color(type))
	label.add_theme_font_size_override("font_size", 12)
	log_list.add_child(label)
	print("label added, child count: ", log_list.get_child_count())
	_trim()
	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

func _trim() -> void:
	while log_list.get_child_count() > MAX_ENTRIES:
		log_list.get_child(0).queue_free()

func _timestamp() -> String:
	var t := Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [t["hour"], t["minute"], t["second"]]

func _color(type: LogType) -> Color:
	match type:
		LogType.ARRIVAL: return Color("#7EB8E8")
		LogType.SALE:    return Color("#96C96A")
		LogType.LEAVE:   return Color("#E07070")
		LogType.AURA:    return Color("#A89EE0")
		LogType.DAY:     return Color("#D4A84B")
		_:               return Color("#888078")
