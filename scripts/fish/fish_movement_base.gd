class_name FishMovementBase
extends Node2D

var fish: Node2D

func _ready():
	await owner.ready
	fish = get_parent()

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_state_timer()
	if fish.hunger >= 500:
		fish.vy *= 0.95
	if fish.hunger < 500:
		var target = _find_nearest_target()
		if target:
			_hungry_behavior(target)
		else:
			_apply_movement_state()
	else:
		_apply_movement_state()
	_check_wall_collision()
	_decelerate_near_walls()
	_detect_direction_change()
	_apply_velocity()

# Override in subclass — guppy finds food, carnivore finds guppies
func _find_nearest_target() -> Node2D:
	return null

# Override in subclass — different acceleration values per fish type
func _hungry_behavior(_target: Node2D):
	pass

func _update_state_timer():
	fish.special_timer += 1

func _apply_movement_state():
	if fish.move_state < 5:
		_apply_state_0_to_4()
	else:
		_apply_state_5_to_9()

func _apply_state_0_to_4():
	match fish.move_state:
		0:	# Gentle drift
			if fish.special_timer > 39:
				fish.special_timer = 0
				fish.vy = 0.5
				if fish.vx < -0.5: fish.vx += 0.5
				elif fish.vx > 0.5: fish.vx -= 0.5
				fish.vx_abs = int(abs(fish.vx))
		1:	# Swim right, drift up
			if fish.special_timer > 39:
				fish.special_timer = 0
				fish.vy = -0.5
				if fish.vx < 1.0: fish.vx += 1.0
				elif fish.vx > 1.0: fish.vx -= 1.0
				fish.vx_abs = int(abs(fish.vx))
		2:	# Swim left, drift up
			if fish.special_timer > 39:
				fish.special_timer = 0
				fish.vy = -0.5
				if fish.vx < -1.0: fish.vx += 1.0
				elif fish.vx > -1.0: fish.vx -= 1.0
				fish.vx_abs = int(abs(fish.vx))
		3:	# Swim left, dive down
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < -1.0: fish.vx += 1.0
				elif fish.vx > -1.0: fish.vx -= 1.0
				if fish.vy < 3.0: fish.vy += 1.0
				elif fish.vy > 3.0: fish.vy -= 1.0
				if fish.vx_abs < 5:
					if fish.vy >= 4.0:
						if fish.position.y > 240:
							fish.move_state = 0
					else:
						fish.vx_abs += 1
				else:
					fish.vx_abs -= 1
			if fish.position.y > 240:
				fish.move_state = 0
		4:	# Swim right, dive down
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < 1.0: fish.vx += 1.0
				elif fish.vx > 1.0: fish.vx -= 1.0
				if fish.vy < 3.0: fish.vy += 1.0
				elif fish.vy > 3.0: fish.vy -= 1.0
				if fish.vx_abs < 5:
					if fish.vy >= 4.0:
						if fish.position.y > 240:
							fish.move_state = 0
					else:
						fish.vx_abs += 1
				else:
					fish.vx_abs -= 1
			if fish.position.y > 240:
				fish.move_state = 0

func _apply_state_5_to_9():
	if fish.special_timer > 39:
		fish.special_timer = 0
		if fish.position.y >= 115.0:
			fish.vy = -0.5
		else:
			fish.vy = -0.1
		var left_bound = fish.x_min + 100.0
		var right_bound = fish.x_max - 100.0
		if fish.x_direction == 1:
			if fish.vx < 0.0: fish.vx += 2.0
			else: fish.vx += 1.0
			fish.vx_abs = int(abs(fish.vx))
			if fish.position.x > right_bound:
				fish.x_direction = -1
				fish.vx -= 2.0
		elif fish.x_direction == -1:
			if fish.vx > 0.0: fish.vx -= 2.0
			else: fish.vx -= 1.0
			fish.vx_abs = int(abs(fish.vx))
			if fish.position.x < left_bound:
				fish.x_direction = 1
				fish.vx += 2.0

func _decelerate_near_walls():
	if fish.position.x > fish.x_max - 5 and fish.vx > 0.1:
		fish.vx -= 0.1
	if fish.position.x < 15 and fish.vx < -0.1:
		fish.vx += 0.1

func _check_wall_collision():
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)

	var hit_left  = fish.position.x <= fish.x_min and fish.vx <= 0
	var hit_right = fish.position.x >= fish.x_max and fish.vx >= 0
	var hit_top   = fish.position.y <= fish.y_min and fish.vy <= 0
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
	if hit_left or hit_right:
		if fish.position.y < fish.y_min + 40:
			fish.vy = randf_range(0.5, 1.0)
		elif fish.position.y > fish.y_max - 40:
			fish.vy = randf_range(-1.0, -0.5)

func _detect_direction_change():
	if fish.prev_vx < 0 and fish.vx > 0:
		fish.turn_timer = -20
	elif fish.prev_vx > 0 and fish.vx < 0:
		fish.turn_timer = 20
	if fish.prev_vx != fish.vx and fish.prev_vx != 0 and fish.vx != 0:
		fish.prev_vx = fish.vx

func _apply_velocity():
	var vx_abs = abs(fish.vx)
	if vx_abs < 1.0:
		fish.position.y += (1.0 / fish.speed_mod) * 0.5
	elif vx_abs < 2.0:
		fish.position.y += (0.75 / fish.speed_mod) * 0.5
	elif vx_abs < 3.0:
		fish.position.y += (0.5 / fish.speed_mod) * 0.5
	elif vx_abs < 4.0:
		fish.position.y += (0.25 / fish.speed_mod) * 0.5
	fish.position.x += (fish.vx / fish.speed_mod) * 0.5
	fish.position.y += (fish.vy / fish.speed_mod) * 0.5
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)
