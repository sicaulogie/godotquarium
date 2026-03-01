class_name FishSpawner

const GuppyScene = preload("res://scenes/fishes/guppy.tscn")
const CarnivoreScene = preload("res://scenes/fishes/carnivore.tscn")

const SPAWN_X_MIN = 60
const SPAWN_X_MAX = 540
const SPAWN_Y_MIN = 100
const SPAWN_Y_MAX = 360

static func spawn_guppy(parent: Node, pos: Vector2 = Vector2(-1, -1)) -> Node:
	if pos.x < 0:
		pos = Vector2(randi_range(SPAWN_X_MIN, SPAWN_X_MAX), randi_range(SPAWN_Y_MIN, SPAWN_Y_MAX))
	var fish = GuppyScene.instantiate()
	fish.position = Vector2(pos.x, 30.0)   # start at top
	parent.add_child(fish)
	fish.entry_vy = randi_range(18, 22)
	fish.bought_timer = randi_range(90, 108)
	_spawn_bubbles(parent, fish.position, 40.0)
	return fish

static func spawn_carnivore(parent: Node, pos: Vector2 = Vector2(-1, -1)) -> Node:
	if pos.x < 0:
		pos = Vector2(randi_range(SPAWN_X_MIN, SPAWN_X_MAX), randi_range(SPAWN_Y_MIN, SPAWN_Y_MAX))
	var fish = CarnivoreScene.instantiate()
	fish.position = Vector2(pos.x, 30.0)   # start at top
	parent.add_child(fish)
	fish.entry_vy = randi_range(18, 22)
	fish.bought_timer = randi_range(90, 108)
	_spawn_bubbles(parent, fish.position, 80.0)
	return fish

static func _spawn_bubbles(parent: Node, pos: Vector2, radius: float):
	var bm = parent.get_node_or_null("BubbleManager")
	if not bm:
		return
	var count = randi_range(3, 6)
	for i in count:
		var angle = randf() * TAU
		var dist = randf() * radius * 0.5
		bm._spawn_bubble_at(pos.x + cos(angle) * dist, pos.y + sin(angle) * dist)
