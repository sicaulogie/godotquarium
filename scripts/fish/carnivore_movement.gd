class_name CarnivoreMovement
extends FishMovementBase

# Override — carnivore searches guppy group
func _find_nearest_target() -> Node2D:
	var nearest = null
	var nearest_dist = INF
	for g in get_tree().get_nodes_in_group("guppies"):
		if not g is Guppy or g.is_dead:
			continue
		var d = fish.position.distance_to(g.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = g
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

# Override — BiFish acceleration values from BiFish.cpp HungryBehavior()
func _hungry_behavior(target: Node2D):
	fish.hungry_timer += 1
	if fish.hungry_timer <= 2:
		return
	fish.hungry_timer = 0

	var center_x = fish.position.x
	var center_y = fish.position.y
	var tcx = target.position.x
	var tcy = target.position.y

	if fish.hunger < 301:
		if center_x > tcx + 44:
			if fish.vx > -6.0: fish.vx -= 1.5
		elif center_x < tcx + 36:
			if fish.vx < 6.0: fish.vx += 1.5
		elif center_x > tcx + 42:
			if fish.vx > -4.0: fish.vx -= 0.2
		elif center_x < tcx - 38:
			if fish.vx < 4.0: fish.vx += 0.2
		elif center_x > tcx + 40:
			if fish.vx > -4.0: fish.vx -= 0.05
		elif center_x < tcx + 40:
			if fish.vx < 4.0: fish.vx += 0.05

		if center_y > tcy + 40:
			if fish.vy > -6.0: fish.vy -= 1.5
		elif center_y < tcy + 40:
			if fish.vy < 6.0: fish.vy += 1.5
	else:
		if center_x > tcx + 44:
			if fish.vx > -3.0: fish.vx -= 1.0
		elif center_x < tcx + 36:
			if fish.vx < 3.0: fish.vx += 1.0
		elif center_x > tcx + 42:
			if fish.vx > -3.0: fish.vx -= 0.1
		elif center_x < tcx + 38:
			if fish.vx < 3.0: fish.vx += 0.1
		elif center_x > tcx + 40:
			if fish.vx > -3.0: fish.vx -= 0.05
		elif center_x < tcx + 40:
			if fish.vx < 3.0: fish.vx += 0.05

		if center_y > tcy + 43:
			if fish.vy > -3.0: fish.vy -= 1.0
		elif center_y < tcy + 37:
			if fish.vy < 3.0: fish.vy += 1.0
		elif center_y > tcy + 40:
			if fish.vy > -3.0: fish.vy -= 0.5
		elif center_y < tcy + 40:
			if fish.vy < 3.0: fish.vy += 0.5

	if fish.vx_abs < 5:
		fish.vx_abs += 1
