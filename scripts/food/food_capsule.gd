extends "res://scripts/food/food_base.gd"

func _ready():
	food_type = 1
	exotic_food_type = 0
	fall_speed = 1.5
	super._ready()

func get_animation_name() -> String:
	return "capsule_green"
