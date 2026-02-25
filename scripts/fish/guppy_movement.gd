extends Node2D

var fish: Node2D
var special_move_timer: int = 0  # mSpecialMovementStateChangeTimer gate

func _ready():
	await owner.ready
	fish = get_parent()

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_state_timer()

	# From Fish.cpp Hungry() line 969 — only chase food when hunger < 500
	if fish.hunger < 500:
		var nearest_food = _find_nearest_food()
		if nearest_food:
			_hungry_behavior(nearest_food)
		else:
			_apply_movement_state()
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

func _hungry_behavior(food: Node2D):
	# From Fish.cpp HungryBehavior() — gated behind special timer > 2
	fish.special_timer += 1
	if fish.special_timer <= 2:
		return
	fish.special_timer = 0

	var center_x = fish.position.x + 40.0
	var center_y = fish.position.y + 40.0
	var fcx = food.position.x + 20.0  # food center x (food width/2 = 20)
	var fcy = food.position.y + 20.0  # food center y

	if fish.hunger < 301:
		# Very hungry — from Fish.cpp lines 1128-1158
		if center_x > fcx + 8:
			if fish.vx > -4.0: fish.vx -= 1.3
		elif center_x < fcx - 8:
			if fish.vx < 4.0: fish.vx += 1.3
		elif center_x > fcx + 4:
			if fish.vx > -4.0: fish.vx -= 0.2
		elif center_x < fcx - 4:
			if fish.vx < 4.0: fish.vx += 0.2
		elif center_x > fcx:
			if fish.vx > -4.0: fish.vx -= 0.05
		elif center_x < fcx:
			if fish.vx < 4.0: fish.vx += 0.05

		if center_y > fcy + 6:
			if fish.vy > -3.0: fish.vy -= 1.0
		elif center_y < fcy - 6:
			if fish.vy < 4.0: fish.vy += 1.3
		elif center_y > fcy:
			if fish.vy > -3.0: fish.vy -= 0.5
		elif center_y < fcy:
			if fish.vy < 4.0: fish.vy += 0.7
	else:
		# Normal hungry — from Fish.cpp lines 1162-1192
		if center_x > fcx + 8:
			if fish.vx > -3.0: fish.vx -= 1.0
		elif center_x < fcx - 8:
			if fish.vx < 3.0: fish.vx += 1.0
		elif center_x > fcx + 4:
			if fish.vx > -3.0: fish.vx -= 0.1
		elif center_x < fcx - 4:
			if fish.vx < 3.0: fish.vx += 0.1
		elif center_x > fcx:
			if fish.vx > -3.0: fish.vx -= 0.05
		elif center_x < fcx:
			if fish.vx < 3.0: fish.vx += 0.05

		if center_y > fcy + 6:
			if fish.vy > -2.0: fish.vy -= 0.6
		elif center_y < fcy - 6:
			if fish.vy < 3.0: fish.vy += 1.0
		elif center_y > fcy:
			if fish.vy > -2.0: fish.vy -= 0.3
		elif center_y < fcy:
			if fish.vy < 3.0: fish.vy += 0.5

	if fish.vx_abs < 5:
		fish.vx_abs += 1

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

func _find_nearest_food() -> Node2D:
	# From Fish.cpp FindNearestFood() — NO distance limit, always finds nearest
	var food_nodes = get_tree().get_nodes_in_group("food")
	var nearest = null
	var nearest_dist = INF
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

func _decelerate_near_walls():
	# From Fish.cpp lines 514-517 — only decelerate near right and left walls
	if fish.position.x > fish.x_max - 5 and fish.vx > 0.1:
		fish.vx -= 0.1
	if fish.position.x < 15 and fish.vx < -0.1:
		fish.vx += 0.1

func _check_wall_collision():
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)

	var hit_left = fish.position.x <= fish.x_min and fish.vx <= 0
	var hit_right = fish.position.x >= fish.x_max and fish.vx >= 0
	var hit_top = fish.position.y <= fish.y_min and fish.vy <= 0
	var hit_bottom = fish.position.y >= fish.y_max and fish.vy >= 0

	if hit_left:
		fish.vx = randf_range(0.5, 1.5)
		fish.move_state = [1, 4, 6][randi() % 3]
		fish.special_timer = 40

	if hit_right:
		fish.vx = randf_range(-1.5, -0.5)
		fish.move_state = [2, 3, 5][randi() % 3]
		fish.special_timer = 40

	if hit_top:
		fish.vy = randf_range(0.5, 1.5)

	if hit_bottom:
		fish.vy = randf_range(-1.5, -0.5)

	# Wide buffer zones near walls — prevent re-entering wall zone
	if hit_left or hit_right:
		if fish.position.y < fish.y_min + 80:
			fish.vy = randf_range(0.5, 1.5)
		elif fish.position.y > fish.y_max - 80:
			fish.vy = randf_range(-1.5, -0.5)

	# Persistent top/bottom drift correction — independent of side walls
	if fish.position.y <= fish.y_min + 10 and fish.vy < 0:
		fish.vy = randf_range(0.5, 1.0)
	if fish.position.y >= fish.y_max - 10 and fish.vy > 0:
		fish.vy = randf_range(-1.0, -0.5)

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
	# Scale by 0.5 to match original 30fps timing at 60fps
	if fish.position.x <= fish.x_min + 5 or fish.position.y <= fish.y_min + 5:
		print("Corner stuck! pos:", fish.position, " vx:", fish.vx, " vy:", fish.vy, " state:", fish.move_state, " special:", fish.special_timer)
	fish.position.x += (fish.vx / fish.speed_mod) * 0.5
	fish.position.y += (fish.vy / fish.speed_mod) * 0.5
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)
