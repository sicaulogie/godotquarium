extends "res://scripts/food/food_base.gd"

func _ready():
	food_type = 3
	exotic_food_type = 0
	fall_speed = 1.2  # potions sink slightly slower
	super._ready()

func get_animation_name() -> String:
	return "potion"
