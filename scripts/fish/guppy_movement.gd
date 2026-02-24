extends Node2D

var fish: Node2D

func _ready():
	await owner.ready
	fish = get_parent()

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_state_timer()

	var nearest_food = _find_nearest_food()

	# Always chase food if it exists nearby — matches original behavior
	if nearest_food:
		_chase_food(nearest_food)
	else:
		_apply_movement_state()

	_decelerate_near_walls()
	_check_wall_collision()
	_detect_direction_change()
	_apply_velocity()

func _update_state_timer():
	fish.special_timer += 1
	fish.move_state_timer += 1
	if fish.move_state_timer > 20:
		fish.move_state_timer = 0
		if randi() % 10 == 0:
			fish.move_state = randi() % 9 + 1

func _apply_movement_state():
	if fish.special_timer <= 39:
		return
	fish.special_timer = 0

	match fish.move_state:
		1:
			if fish.vx < 1.0: fish.vx += 1.0
			elif fish.vx > 1.0: fish.vx -= 1.0
			fish.vy = -0.5
			fish.vx_abs = int(abs(fish.vx))
		2:
			if fish.vx < -1.0: fish.vx += 1.0
			elif fish.vx > -1.0: fish.vx -= 1.0
			fish.vy = -0.5
			fish.vx_abs = int(abs(fish.vx))
		3, 4, 5, 6:
			var target = [-2.0, 2.0, -1.5, 1.5][fish.move_state - 3]
			if fish.vx < target: fish.vx += 0.5
			elif fish.vx > target: fish.vx -= 0.5
			if fish.vy < 1.0: fish.vy += 0.3
			elif fish.vy > 1.0: fish.vy -= 0.3
			fish.vx_abs = int(abs(fish.vx))
		_:
			if fish.vx < -0.5: fish.vx += 0.5
			elif fish.vx > 0.5: fish.vx -= 0.5
			fish.vx_abs = int(abs(fish.vx))

func _food_in_range(food: Node2D, radius: float) -> bool:
	return fish.position.distance_to(food.position) < radius

func _find_nearest_food() -> Node2D:
	var food_nodes = get_tree().get_nodes_in_group("food")
	var nearest = null
	# From Fish.cpp — only react to food within ~100px
	# Use different awareness radius per hunger level
	var awareness_radius = 100.0
	if fish.hunger < 301:
		awareness_radius = 200.0  # very hungry — wider search
	elif fish.hunger < 500:
		awareness_radius = 150.0  # hungry — medium search

	var nearest_dist = awareness_radius  # only find within radius

	for f in food_nodes:
		if f.get("cant_eat_timer") != null and f.cant_eat_timer > 0:
			continue
		if f.get("picked_up") != null and f.picked_up:
			continue
		var d = fish.position.distance_to(f.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = f
	return nearest

func _chase_food(food: Node2D):
	var speed = 2.0 if fish.hunger < 301 else 1.5
	var center = fish.position + Vector2(40, 40)
	var food_center = food.position + Vector2(20, 20)
	var diff = food_center - center

	if diff.x > 8:
		if fish.vx < speed: fish.vx += 1.3
	elif diff.x < -8:
		if fish.vx > -speed: fish.vx -= 1.3
	elif diff.x > 4:
		if fish.vx < speed: fish.vx += 0.2
	elif diff.x < -4:
		if fish.vx > -speed: fish.vx -= 0.2
	elif diff.x > 0:
		if fish.vx < speed: fish.vx += 0.05
	elif diff.x < 0:
		if fish.vx > -speed: fish.vx -= 0.05

	if diff.y > 6:
		if fish.vy < speed: fish.vy += 1.0
	elif diff.y < -6:
		if fish.vy > -speed: fish.vy -= 1.0
	elif diff.y > 0:
		if fish.vy < speed: fish.vy += 0.5
	elif diff.y < 0:
		if fish.vy > -speed: fish.vy -= 0.3

	fish.vx_abs = min(fish.vx_abs + 1, 5)

func _decelerate_near_walls():
	if fish.position.x > fish.x_max - 5 and fish.vx > 0.1:
		fish.vx -= 0.1
	if fish.position.x < fish.x_min + 15 and fish.vx < -0.1:
		fish.vx += 0.1

func _check_wall_collision():
	if fish.position.x >= fish.x_max and fish.vx > 0:
		fish.vx = -abs(fish.vx) * 0.5
		fish.move_state = 2
	if fish.position.x <= fish.x_min and fish.vx < 0:
		fish.vx = abs(fish.vx) * 0.5
		fish.move_state = 1

func _detect_direction_change():
	if fish.prev_vx < 0 and fish.vx > 0:
		fish.turn_timer = -20
	elif fish.prev_vx > 0 and fish.vx < 0:
		fish.turn_timer = 20

	if fish.turn_timer > 0: fish.turn_timer -= 1
	elif fish.turn_timer < 0: fish.turn_timer += 1

	if fish.prev_vx != fish.vx and fish.prev_vx != 0 and fish.vx != 0:
		fish.prev_vx = fish.vx

func _apply_velocity():
	fish.position.x += fish.vx / fish.speed_mod
	fish.position.y += fish.vy / fish.speed_mod

	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)
