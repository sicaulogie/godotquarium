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

# Override — BiFish acceleration values from BiFish.cpp HungryBehavior()
func _hungry_behavior(target: Node2D):
	fish.hungry_timer += 1
	if fish.hungry_timer <= 2:
		return
	fish.hungry_timer = 0

	var center_x = fish.position.x + 40.0
	var center_y = fish.position.y + 40.0
	var tcx = target.position.x + 40.0
	var tcy = target.position.y + 40.0

	if fish.hunger < 301:
		if center_x > tcx + 44:
			if fish.vx > -4.0: fish.vx -= 1.3
		elif center_x < tcx + 36:
			if fish.vx < 4.0: fish.vx += 1.3
		elif center_x > tcx + 42:
			if fish.vx > -4.0: fish.vx -= 0.2
		elif center_x < tcx - 38:
			if fish.vx < 4.0: fish.vx += 0.2
		elif center_x > tcx + 40:
			if fish.vx > -4.0: fish.vx -= 0.05
		elif center_x < tcx + 40:
			if fish.vx < 4.0: fish.vx += 0.05

		if center_y > tcy + 40:
			if fish.vy > -4.0: fish.vy -= 1.3
		elif center_y < tcy + 40:
			if fish.vy < 4.0: fish.vy += 1.3
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
