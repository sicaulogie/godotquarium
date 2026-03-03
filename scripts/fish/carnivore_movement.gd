class_name CarnivoreMovement
extends FishMovementBase

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
			"accel_x_far": 0.75, "accel_x_mid": 0.3, "accel_x_near": 0.1, "cap_x": 6.0,
			"accel_y_far": 0.6, "accel_y_far_down": 0.75, "accel_y_near": 0.6, "accel_y_near_down": 0.8,
			"cap_y_up": 5.0, "cap_y_down": 6.0
		},
		"satisfied": {
			"accel_x_far": 0.55, "accel_x_mid": 0.2, "accel_x_near": 0.05, "cap_x": 3.0,
			"accel_y_far": 0.8, "accel_y_far_down": 1.1, "accel_y_near": 0.4, "accel_y_near_down": 0.6,
			"cap_y_up": 3.0, "cap_y_down": 4.0
		}
	}

func _get_target_group() -> String:
	return "guppies"

func _is_valid_target(candidate: Node2D) -> bool:
	return candidate is Guppy and not candidate.is_dead and candidate.size == Guppy.Size.SMALL
