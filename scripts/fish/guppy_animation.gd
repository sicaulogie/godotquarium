extends Node2D
var fish: Node2D
var body: AnimatedSprite2D
var current_prefix: String = "small"
var current_state: String = "swim"
var current_anim: String = "small_swim"

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
		3: return "king"
		_: return "small"

func _update_animation():
	if _update_growth_transition():
		return
	_update_eat_state()
	_update_state()
	_update_hunger_suffix()
	_update_frame_index()
	_update_scale()

# Returns true if transition is active and takes full control
func _update_growth_transition() -> bool:
	if fish.growth_transition_timer <= 0:
		return false

	fish.growth_transition_timer -= 1

	if fish.growth_transition_timer == 0:
		fish.eating_timer = 0
		fish.was_eating = false
		fish.eat_frame = 0
		fish.was_hungry = false
		fish.hunger_anim_timer = 0
		return true

	var anim: String
	if fish.growth_transition_timer > 10:
		# First half — use hungry eat if fish was hungry, normal eat if not
		anim = "large_eat_hungry" if fish.was_hungry_at_transition else "large_eat"
		if body.animation != anim:
			body.set_animation(anim)
		fish.anim_frame_index = clamp(4 - ((fish.growth_transition_timer - 10) / 2), 0, 4)
	else:
		# Second half — always use normal king eat (not hungry)
		if fish.size != 3:
			fish.size = 3
		anim = "king_eat"
		if body.animation != anim:
			body.set_animation(anim)
		fish.anim_frame_index = clamp(5 + ((10 - fish.growth_transition_timer) / 2), 5, 9)

	body.frame = fish.anim_frame_index
	body.scale = Vector2(1.0, 1.0)  # no scale for king transition
	return true

# Manages was_eating flag and eat_frame reset
func _update_eat_state():
	if fish.eating_timer > 0 and not fish.was_eating:
		fish.eat_frame = 0
		fish.was_eating = true
	elif fish.eating_timer == 0:
		fish.was_eating = false

# Determines current state (turn/eat/swim) and builds anim string
func _update_state():
	current_prefix = _get_size_prefix()
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
	current_anim = current_prefix + "_" + current_state

func _update_hunger_suffix():
	if current_state == "eat":
		# During eat — suffix already locked by was_hungry snapshot in _eat_food
		# Just append if was hungry before eating, no blending
		if fish.was_hungry:
			current_anim += "_hungry"
		if body.animation != current_anim:
			var old_frame = body.frame
			body.set_animation(current_anim)
			body.frame = clamp(old_frame, 0, body.sprite_frames.get_frame_count(current_anim) - 1)
		return

	# Not eating — normal hunger state management
	var is_hungry = fish.hunger < 0
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

	if fish.was_hungry and fish.hunger_anim_timer <= 5:
		current_anim += "_hungry"
	elif not fish.was_hungry and fish.hunger_anim_timer < -5:
		current_anim += "_hungry"

	if body.animation != current_anim:
		var old_frame = body.frame
		body.set_animation(current_anim)
		body.frame = clamp(old_frame, 0, body.sprite_frames.get_frame_count(current_anim) - 1)
		if current_state == "swim":
			fish.swim_frame_counter = 0.0

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

# Handles growth scale pop
func _update_scale():
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

	# Hunger number
	draw_string(ThemeDB.fallback_font, Vector2(0, 0),
		str(fish.hunger), HORIZONTAL_ALIGNMENT_CENTER, 60, 12, Color.WHITE)

	# Feed progress counter — shows food_ate / food_needed_to_grow
	var remaining = fish.food_needed_to_grow - fish.food_ate
	var progress_text = str(remaining)
	draw_string(ThemeDB.fallback_font, Vector2(0, 14),
		progress_text, HORIZONTAL_ALIGNMENT_CENTER, 60, 10, Color.YELLOW)
