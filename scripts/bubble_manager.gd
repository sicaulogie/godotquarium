class_name BubbleManager
extends Node2D

const BubbleScene = preload("res://scenes/bubble.tscn")
const MAX_BUBBLES = 30   # Board.cpp line 1698 — cap for normal spawns
const BUBBLE_Y_TOP = 0

func _physics_process(_delta):
	# Remove bubbles that reached the top
	for child in get_children():
		if child.position.y < BUBBLE_Y_TOP:
			child.queue_free()

	if get_child_count() >= MAX_BUBBLES:
		return

	# System 1 — single trickle, ~1/1000 per frame
	if randi() % 1000 < 2:
		_spawn_bubble()

	# System 2 — occasional burst of 2-4, separate 1/1000 roll
	if randi() % 1000 == 0:
		var count = randi_range(2, 4)
		for i in count:
			_spawn_bubble()
		# TODO: PlaySample(SOUND_BUBBLES_ID)

func _spawn_bubble():
	# From Board.cpp line 1705 — narrow band x=150-172, y=400-406
	var bubble = BubbleScene.instantiate()
	bubble.position = Vector2(
		randi_range(150, 172),
		randi_range(400, 406)
	)
	add_child(bubble)

func _spawn_bubble_at(x: float, y: float):
	if get_child_count() >= 50:  # higher cap for fish entry bubbles
		return
	var bubble = BubbleScene.instantiate()
	bubble.position = Vector2(x, y)
	add_child(bubble)
