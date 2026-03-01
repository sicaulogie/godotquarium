class_name FishAnimationBase
extends Node2D

var fish: Node2D
var body: AnimatedSprite2D
var current_state: String = "swim"
var current_anim: String = "swim"

func _ready():
	await owner.ready
	fish = get_parent()
	body = fish.get_node("Body")

func _physics_process(_delta):
	if not is_instance_valid(fish) or not is_instance_valid(body):
		return
	_update_animation()

# Override in subclass to build the full animation name
# Guppy prefixes with size (small_swim), carnivore has no prefix (swim)
func _update_animation():
	_update_state()
	_update_hunger_suffix()
	_update_frame_index()

# Override in subclass if prefix needed (guppy) or not (carnivore)
func _build_anim_name(state: String) -> String:
	return state

func _update_state():
	if fish.turn_timer != 0:
		current_state = "turn"
		fish.turn_tick += 1
		if fish.turn_tick >= 2:
			fish.turn_tick = 0
			if fish.turn_timer > 0: fish.turn_timer -= 1
			elif fish.turn_timer < 0: fish.turn_timer += 1
	else:
		current_state = "swim"
	current_anim = _build_anim_name(current_state)

func _update_hunger_suffix():
	if current_state == "eat":
		if fish.was_hungry:
			current_anim += "_hungry"
		if body.animation != current_anim:
			var old_frame = body.frame
			body.set_animation(current_anim)
			body.frame = clamp(old_frame, 0, body.sprite_frames.get_frame_count(current_anim) - 1)
		return

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
	else:  # swim (and eat handled by subclass)
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

func _process(_delta):
	queue_redraw()

func _draw():
	if not is_instance_valid(fish):
		return
	draw_string(ThemeDB.fallback_font, Vector2(0, 0),
		str(fish.hunger), HORIZONTAL_ALIGNMENT_CENTER, 60, 12, Color.WHITE)
