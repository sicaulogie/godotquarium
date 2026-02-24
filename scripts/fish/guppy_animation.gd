extends Node2D

var fish: Node2D
var body: AnimatedSprite2D

func _ready():
	# Wait for parent to be fully ready
	await owner.ready
	fish = get_parent()
	body = fish.get_node("Body")
	body.pause()

func _physics_process(_delta):
	if not is_instance_valid(fish) or not is_instance_valid(body):
		return
	_update_animation()

func _get_size_prefix() -> String:
	if not fish or not body:
		return "small"
	match fish.size:
		fish.Size.SMALL:   return "small"
		fish.Size.MEDIUM:  return "medium"
		fish.Size.LARGE:   return "large"
		fish.Size.CROWNED: return "large"
		_:                 return "small"

func _update_animation():
	var prefix = _get_size_prefix()

	if fish.turn_timer != 0:
		var anim = prefix + "_turn"
		if body.animation != anim:
			body.set_animation(anim)

		# From Fish.cpp — direction determines frame order
		# turn_timer > 0 means turning left: frames go 9→0
		# turn_timer < 0 means turning right: frames go 0→9
		if fish.turn_timer > 0:
			fish.anim_frame_index = 9 - (fish.turn_timer / 2)
		else:
			fish.anim_frame_index = 9 + (fish.turn_timer / 2)

	else:
		var anim = prefix + "_swim"
		if body.animation != anim:
			body.set_animation(anim)
			# Start swim from frame 0 cleanly after turn finishes
			fish.swim_frame_counter = 0

		if fish.vx_abs < 2:
			fish.swim_frame_counter += 0.5
		else:
			fish.swim_frame_counter += 1.0

		if fish.swim_frame_counter >= 20:
			fish.swim_frame_counter = 0

		fish.anim_frame_index = fish.swim_frame_counter / 2

	fish.anim_frame_index = clamp(
		fish.anim_frame_index, 0,
		body.sprite_frames.get_frame_count(body.animation) - 1
	)

	body.frame = fish.anim_frame_index

	# Only flip during swim — during turn the sprite handles direction
	# via frame order, not flipping
	if fish.turn_timer == 0:
		body.flip_h = fish.vx > 0.0

func _process(_delta):
	queue_redraw()  # tells Godot to call _draw every frame
