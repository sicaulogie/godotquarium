extends Node2D

const FishScene = preload("res://scenes/fish.tscn")
const FoodScene = preload("res://scenes/food/food.tscn")

var current_food_type: int = 2
var food_type_names = ["Base", "Pellet", "Capsule"]

func _ready():
	_spawn_fish(150, 200, false)
	_spawn_fish(300, 250, false)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_drop_food(event.position)

	# Press Tab to cycle food types
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			current_food_type = (current_food_type + 1) % 3
			print("Food type: ", food_type_names[current_food_type])

# Food placement boundaries from Fish.cpp line 620
const FOOD_X_MIN = 30.0
const FOOD_X_MAX = 587.0
const FOOD_Y_MIN = 60.0
const FOOD_Y_MAX = 400.0

func _drop_food(pos: Vector2):
	# Clamp to original boundaries — fish will never get pulled to walls
	var clamped = Vector2(
		clamp(pos.x, FOOD_X_MIN, FOOD_X_MAX),
		clamp(pos.y, FOOD_Y_MIN, FOOD_Y_MAX)
	)
	var food = FoodScene.instantiate()
	food.position = clamped
	food.food_type = current_food_type
	add_child(food)

func _spawn_fish(x: float, y: float, bought: bool = true):
	var fish = FishScene.instantiate()
	fish.position = Vector2(x, 30.0 if bought else y)
	add_child(fish)
	if bought:
		fish.entry_vy = randi_range(9, 11)
		fish.bought_timer = randi_range(90, 108)
	else:
		fish.bought_timer = 0  # already in tank, no entry
		fish.position = Vector2(x, y)

# Display current food type on screen
func _draw():
	draw_string(
		ThemeDB.fallback_font,
		Vector2(10, 470),
		"Food: " + food_type_names[current_food_type] + " (Tab to switch)",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color.WHITE
	)

func _process(_delta):
	queue_redraw()
