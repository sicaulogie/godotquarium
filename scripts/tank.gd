extends Node2D

const FishScene = preload("res://scenes/fish.tscn")
const FoodScene = preload("res://scenes/food/food.tscn")

func _ready():
	_spawn_fish(150, 200)
	_spawn_fish(300, 250)
	_spawn_fish(420, 180)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_drop_food(event.position)

func _spawn_fish(x: float, y: float):
	var fish = FishScene.instantiate()
	fish.position = Vector2(x, y)
	add_child(fish)

func _drop_food(pos: Vector2):
	var food = FoodScene.instantiate()
	# Spawn slightly above click like original
	food.position = Vector2(pos.x, pos.y - 20)
	add_child(food)
