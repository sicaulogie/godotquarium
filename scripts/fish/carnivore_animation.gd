class_name CarnivoreAnimation
extends FishAnimationBase

# No prefix needed — carnivore animations are "swim", "eat", "turn" etc.
func _build_anim_name(state: String) -> String:
	return state

# Override — carnivore has eat state (no growth transition, no scale pop)
func _update_state():
	if fish.turn_timer != 0:
		current_state = "turn"
		fish.turn_tick += 1
		if fish.turn_tick >= 2:
			fish.turn_tick = 0
			if fish.turn_timer > 0: fish.turn_timer -= 1
			elif fish.turn_timer < 0: fish.turn_timer += 1
	elif fish.eating_timer > 0:
		current_state = "eat"
		if Engine.get_process_frames() % 2 == 0:
			fish.eating_timer -= 1
	else:
		current_state = "swim"
	current_anim = _build_anim_name(current_state)

# Override — carnivore eat frame advances independently
func _update_frame_index():
	if current_state == "turn":
		if fish.turn_timer > 0:
			body.flip_h = true
			fish.anim_frame_index = 9 - (fish.turn_timer / 2)
		else:
			body.flip_h = false
			fish.anim_frame_index = 9 + (fish.turn_timer / 2)
	elif current_state == "eat":
		if Engine.get_process_frames() % 2 == 0:
			fish.eat_frame += 1
		fish.eat_frame = min(fish.eat_frame, 9)
		fish.anim_frame_index = clamp(fish.eat_frame, 0, 9)
		if fish.vx < 0.0:       body.flip_h = false
		elif fish.vx > 0.0:     body.flip_h = true
		else:                   body.flip_h = fish.prev_vx > 0.0
	else:  # swim
		if fish.vx_abs < 2:
			fish.swim_frame_counter += 0.5
		else:
			fish.swim_frame_counter += 1.0
		if fish.swim_frame_counter >= 20:
			fish.swim_frame_counter = 0.0
		fish.anim_frame_index = int(fish.swim_frame_counter / 2.0)
		if fish.vx < 0.0:       body.flip_h = false
		elif fish.vx > 0.0:     body.flip_h = true
		else:                   body.flip_h = fish.prev_vx > 0.0

	fish.anim_frame_index = clamp(
		fish.anim_frame_index, 0,
		body.sprite_frames.get_frame_count(body.animation) - 1
	)
	body.frame = fish.anim_frame_index
