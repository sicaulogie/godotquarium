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

# In GuppyMovement.gd

func _get_movement_cfg():
	return {
		"starving": {
			"accel_x_far": 0.65, "accel_x_mid": 0.1, "accel_x_near": 0.05, "cap_x": 4.0,
			"accel_y_far": 0.5, "accel_y_far_down": 0.65, "accel_y_near": 0.5, "accel_y_near_down": 0.7,
			"cap_y_up": 3.0, "cap_y_down": 4.0
		},
		"satisfied": {
			"accel_x_far": 0.5, "accel_x_mid": 0.1, "accel_x_near": 0.05, "cap_x": 3.0,
			"accel_y_far": 0.3, "accel_y_far_down": 0.5, "accel_y_near": 0.3, "accel_y_near_down": 0.5,
			"cap_y_up": 2.0, "cap_y_down": 4.0
		}
	}

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

func _apply_entry_velocity():
	fish.position.y += (fish.entry_vy / fish.speed_mod) * 0.5
	fish.position.y = clamp(fish.position.y, -100.0, fish.y_max)
