extends Node2D
var fish: Node2D
var body: AnimatedSprite2D

func _ready():
	await owner.ready # Wait for parent to be fully ready
	fish = get_parent()
	body = fish.get_node("Body")

func _physics_process(_delta):
	if not is_instance_valid(fish) or not is_instance_valid(body):
		return
	_update_animation()

func _get_size_prefix() -> String:
	if not fish:
		return "small"
	match fish.size:
		0: return "small"
		1: return "medium"
		2: return "large"
		3: return "large"
		_: return "small"

func _update_animation():
	var prefix = _get_size_prefix()
	var state: String

	# turning animation
	if fish.turn_timer != 0:
		state = "turn"
		fish.turn_tick += 1
		if fish.turn_tick >= 2:
			fish.turn_tick = 0
			if fish.turn_timer > 0: fish.turn_timer -= 1
			elif fish.turn_timer < 0: fish.turn_timer += 1
	elif fish.eating_timer > 0:
		state = "eat"
		if Engine.get_process_frames() % 2 == 0:
			fish.eating_timer -= 1
	else:
		state = "swim"

	var anim = prefix + "_" + state
	
	var is_hungry = fish.hunger < 200

	if is_hungry and not fish.was_hungry:
		fish.was_hungry = true
		fish.hunger_anim_timer = 10
	elif not is_hungry and fish.was_hungry:
		fish.was_hungry = false
		fish.hunger_anim_timer = -10

	if fish.hunger_anim_timer > 0:
		fish.hunger_anim_timer -= 1
	elif fish.hunger_anim_timer < 0:
		fish.hunger_anim_timer += 1

	# Switch animation at halfway point — no alpha fade, no transparency
	if is_hungry and fish.hunger_anim_timer <= 5:
		anim += "_hungry"
	elif not is_hungry and fish.hunger_anim_timer < -5:
		anim += "_hungry"

	if body.animation != anim:
		var old_frame = body.frame
		body.set_animation(anim)
		# Carry frame index over to prevent one-frame blank
		body.frame = clamp(old_frame, 0, body.sprite_frames.get_frame_count(anim) - 1)
		if state == "swim":
			fish.swim_frame_counter = 0.0

	if state == "turn":
		if fish.turn_timer > 0:
			body.flip_h = true
			fish.anim_frame_index = 9 - (fish.turn_timer / 2)
		else:
			body.flip_h = false
			fish.anim_frame_index = 9 + (fish.turn_timer / 2)
			
	elif state == "eat":
		if Engine.get_process_frames() % 2 == 0:
			fish.eat_frame += 1
		fish.anim_frame_index = clamp(fish.eat_frame, 0, 9)
		# Always update flip when not turning
		if fish.vx < 0.0:
			body.flip_h = false
		elif fish.vx > 0.0:
			body.flip_h = true
		else:
			body.flip_h = fish.prev_vx > 0.0
	else:  # swim
		if fish.vx_abs < 2:
			fish.swim_frame_counter += 0.5
		else:
			fish.swim_frame_counter += 1.0
		if fish.swim_frame_counter >= 20:
			fish.swim_frame_counter = 0.0
		fish.anim_frame_index = int(fish.swim_frame_counter / 2.0)
		# Always update flip when not turning
		if fish.vx < 0.0:
			body.flip_h = false
		elif fish.vx > 0.0:
			body.flip_h = true
		else:
			body.flip_h = fish.prev_vx > 0.0

	fish.anim_frame_index = clamp(
		fish.anim_frame_index, 0,
		body.sprite_frames.get_frame_count(body.animation) - 1
	)
	body.frame = fish.anim_frame_index
	if fish.growth_timer > 0:
		var growth_val: float
		if fish.growth_timer > 6:
			growth_val = ((20.0 - fish.growth_timer) * 0.7) / 14.0 + 0.5
		else:
			growth_val = (fish.growth_timer * 0.2) / 6.0 + 1.0
		body.scale = Vector2(growth_val, growth_val)
		fish.growth_timer -= 1
	else:
		body.scale = Vector2(1.0, 1.0)
	
func _process(_delta):
	queue_redraw()

func _draw():
	if not is_instance_valid(fish) or not is_instance_valid(body):
		return

	# Hunger number below fish — white text with dark outline for readability
	var hunger_text = str(fish.hunger)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(0, 0),   # below the 80px sprite
		hunger_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		60,
		12,
		Color.WHITE
	)
