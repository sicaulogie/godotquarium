class_name CarnivoreMovement
extends FishMovementBase

# Override — carnivore searches guppy group
func _find_nearest_target() -> Node2D:
	var nearest = null
	var nearest_dist = INF
	for g in get_tree().get_nodes_in_group("guppies"):
		if not g is Guppy or g.is_dead:
			continue
		var d = fish.position.distance_squared_to(g.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = g
	if nearest_dist > 10000:
		return null
	return nearest

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	if fish.bought_timer > 0:
		_update_entry()
		_check_wall_collision()
		_apply_entry_velocity()
		return
	super._physics_process(_delta)

func _get_movement_cfg():
	return {
		"starving": {
			"accel_x_far": 1.5, "accel_x_mid": 0.3, "accel_x_near": 0.1, "cap_x": 12.0,
			"accel_y_far": 1.2, "accel_y_far_down": 1.5, "accel_y_near": 0.6, "accel_y_near_down": 0.8,
			"cap_y_up": 10.0, "cap_y_down": 12.0
		},
		"satisfied": {
			"accel_x_far": 1.1, "accel_x_mid": 0.2, "accel_x_near": 0.05, "cap_x": 8.0,
			"accel_y_far": 0.8, "accel_y_far_down": 1.1, "accel_y_near": 0.4, "accel_y_near_down": 0.6,
			"cap_y_up": 6.0, "cap_y_down": 8.0
		}
	}
