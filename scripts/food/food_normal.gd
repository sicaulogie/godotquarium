extends "res://scripts/food/food_base.gd"

func _ready():
	food_type = 0
	exotic_food_type = 0
	super._ready()

func get_animation_name() -> String:
	return "food_pellet"
