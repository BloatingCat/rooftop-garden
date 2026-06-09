class_name GuestData
extends Resource

@export_group("Identity")
@export var species_id: String = ""
@export var species_name: String = ""

@export_group("Behaviour")
@export var patience_sec: float = 12.0
@export var move_speed: float = 60.0
@export var wander_radius: float = 120.0
@export var wander_wait_min: float = 1.5
@export var wander_wait_max: float = 4.0
@export var arrive_distance: float = 12.0

@export_group("Aura")
@export var aura_per_tick: int = 1
@export var aura_tick_sec: float = 2.0

@export_group("Sprites")
@export var body_texture: Texture2D
@export var tail_texture: Texture2D
@export var eye_textures: Array[Texture2D] = []
@export var top_textures: Array[Texture2D] = []

@export_group("Tints")
@export var body_tints: Array[Color] = []
@export var eye_colors: Array[Color] = []
