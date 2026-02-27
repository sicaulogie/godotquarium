extends Node2D

const BubbleScene = preload("res://scenes/bubble.tscn")

const MAX_BUBBLES = 10
const SPAWN_CHANCE = 10  # percent per frame

# Tank bounds from original
const BUBBLE_X_MIN = 0
const BUBBLE_X_MAX = 620
const BUBBLE_Y_TOP = 0    # removed when y < this
const BUBBLE_Y_BOTTOM = 480

func _physics_process(_delta):
	# Remove bubbles that reached the top
	for child in get_children():
		if child.position.y < BUBBLE_Y_TOP:
			child.queue_free()

	# Spawn new bubbles
	if get_child_count() < MAX_BUBBLES:
		if randi() % 100 < SPAWN_CHANCE:
			_spawn_bubble()

func _spawn_bubble():
	var bubble = BubbleScene.instantiate()
	# From Board.cpp line 1705 — narrow band x=150-172, y=400-406
	bubble.position = Vector2(
		randi_range(150, 172),
		randi_range(400, 406)
	)
	add_child(bubble)

func _spawn_bubble_random_wide():
	var bubble = BubbleScene.instantiate()
	# From BubbleMgr::SpawnRandomBubble — full tank width
	bubble.position = Vector2(
		randi_range(0, 620),
		480
	)
	add_child(bubble)

func _spawn_bubble_at(x: float, y: float):
	if get_child_count() >= 50:  # Board.cpp line 1698 cap
		return
	var bubble = BubbleScene.instantiate()
	bubble.position = Vector2(x, y)
	add_child(bubble)
