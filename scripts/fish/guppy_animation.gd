extends Node2D
var fish: Node2D
var body: AnimatedSprite2D

func _ready():
	await owner.ready # Wait for parent to be fully ready
	fish = get_parent()
	body = fish.get_node("Body")
	body.pause()

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
	if body.animation != anim:
		body.set_animation(anim)
		if state == "swim":
			fish.swim_frame_counter = 0.0

	if state == "turn":
		if fish.turn_timer > 0:
			fish.anim_frame_index = 9 - (fish.turn_timer / 2)
		else:
			fish.anim_frame_index = 9 + (fish.turn_timer / 2)
	elif state == "eat":
		if Engine.get_process_frames() % 2 == 0:
			fish.eat_frame += 1
			fish.eating_timer -= 1
		fish.anim_frame_index = clamp(fish.eat_frame, 0, 9) # eat_frame 0→9 maps to frames 0→9 (open and close mouth naturally)
	else:  # swim state
	# From Fish.cpp — tail always moves, minimum increment of 1
	# vx_abs 0 or 1 = slow tail, 2+ = fast tail
		if fish.vx_abs < 2:
			fish.swim_frame_counter += 0.5   # slow at 60fps
		else:
			fish.swim_frame_counter += 1.0   # fast at 60fps

		# Guarantee minimum movement even when vx is exactly 0
		if fish.swim_frame_counter == fish.anim_frame_index * 2:
			fish.swim_frame_counter += 0.5

		if fish.swim_frame_counter >= 20:
			fish.swim_frame_counter = 0.0

		fish.anim_frame_index = int(fish.swim_frame_counter) / 2

	fish.anim_frame_index = clamp(
		fish.anim_frame_index, 0,
		body.sprite_frames.get_frame_count(body.animation) - 1
	)
	body.frame = fish.anim_frame_index
	if fish.turn_timer == 0:
		body.flip_h = fish.vx > 0.0

#show hunger level of fish
func _process(_delta):
	queue_redraw()

func _draw():
	if not is_instance_valid(fish):
		return

	# Hunger indicator rectangles

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
