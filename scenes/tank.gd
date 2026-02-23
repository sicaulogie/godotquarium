extends Node2D

const FishScene = preload("res://scenes/Fish.tscn")

func _ready():
	_spawn_fish(150, 200)
	_spawn_fish(300, 250)
	_spawn_fish(420, 180)

func _spawn_fish(x: float, y: float):
	var fish = FishScene.instantiate()
	fish.position = Vector2(x, y)
	add_child(fish)
