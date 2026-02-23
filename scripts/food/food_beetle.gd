# scripts/food/food_beetle.gd
extends "res://scripts/food/food_base.gd"

func _ready():
	food_type = 0
	exotic_food_type = 2  # from Fish.cpp CanEatFood()
	fall_speed = 0.0      # beetles don't fall, they walk
