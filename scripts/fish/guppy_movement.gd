class_name GuppyMovement
extends FishMovementBase

var had_food_last_frame: bool = false

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return

	if fish.bought_timer > 0:
		_update_entry()
		_check_wall_collision()
		_apply_entry_velocity()
		return  # skip normal movement while entering

	super._physics_process(_delta)

# Override — guppy searches food group
func _find_nearest_target() -> Node2D:
	var nearest = null
	var nearest_dist = INF
	for f in get_tree().get_nodes_in_group("food"):
		if not f is FoodBase:
			continue
		if f.cant_eat_timer > 0 or f.picked_up:
			continue
		var d = fish.position.distance_to(f.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = f
	return nearest

# Override — guppy-specific acceleration values from Fish.cpp
func _hungry_behavior(food: Node2D):
	fish.hungry_timer += 1
	if fish.hungry_timer <= 2:
		return
	fish.hungry_timer = 0

	var center_x = fish.position.x + 40.0
	var center_y = fish.position.y + 40.0
	var fcx = food.position.x + 20.0
	var fcy = food.position.y + 20.0

	if fish.hunger < 301:
		if center_x > fcx + 6:
			if fish.vx > -1.5: fish.vx -= 1.0
		elif center_x < fcx - 6:
			if fish.vx < 1.5: fish.vx += 1.3
		elif center_x > fcx + 4:
			if fish.vx > -1.5: fish.vx -= 0.5
		elif center_x < fcx - 4:
			if fish.vx < 1.5: fish.vx += 0.7
		elif center_x > fcx:
			if fish.vx > -4.0: fish.vx -= 0.05
		elif center_x < fcx:
			if fish.vx < 4.0: fish.vx += 0.05

		if center_y > fcy + 6:
			if fish.vy > -1.5: fish.vy -= 0.6
		elif center_y < fcy - 6:
			if fish.vy < 1.5: fish.vy += 1.0
		elif center_y > fcy:
			if fish.vy > -1.5: fish.vy -= 0.3
		elif center_y < fcy:
			if fish.vy < 1.5: fish.vy += 0.5
	else:
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

# --- Entry system (guppy-only) ---

func _update_entry():
	fish.bought_timer -= 1
	fish.entry_vy *= 0.949

	if fish.bought_timer >= 62:
		entry_bubble_tick += 1
		if entry_bubble_tick < 2:
			return
		entry_bubble_tick = 0
		var chance = 1 if fish.bought_timer > 80 else 2
		if randi() % chance == 0:
			_spawn_entry_bubbles()

func _spawn_entry_bubbles():
	var tank = fish.get_parent()
	var bubble_mgr = tank.get_node("BubbleManager")
	var body = fish.get_node("Body")
	var half_w = 40.0
	var half_h = 40.0
	if body and body.sprite_frames:
		var frame_tex = body.sprite_frames.get_frame_texture(body.animation, body.frame)
		if frame_tex:
			half_w = frame_tex.get_width() * 0.5 * body.scale.x
			half_h = frame_tex.get_height() * 0.5 * body.scale.y

	if fish.size == 0:
		if randi() % 2 == 0:
			bubble_mgr._spawn_bubble_at(
				fish.position.x - half_w + randf_range(10, 40),
				fish.position.y - half_h + randf_range(10, 40)
			)
	else:
		bubble_mgr._spawn_bubble_at(
			fish.position.x - half_w + randf_range(-5, 55),
			fish.position.y - half_h + randf_range(-5, 55)
		)
		bubble_mgr._spawn_bubble_at(
			fish.position.x - half_w + randf_range(5, 45),
			fish.position.y - half_h + randf_range(5, 45)
		)

func _apply_entry_velocity():
	fish.position.y += (fish.entry_vy / fish.speed_mod) * 0.5
	fish.position.y = clamp(fish.position.y, -100.0, fish.y_max)
