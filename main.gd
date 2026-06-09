extends Node2D


@onready var cat: Cat = $BlackCat
@onready var joystick: Joystick = $UI/Joystick

func _ready():
	cat.joystick = joystick
	#print_tree_pretty()
