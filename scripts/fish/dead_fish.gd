extends Node2D

var vx: float = 0.0
var vy: float = 0.0
var speed_mod: float = 1.8
var fish_size: int = 0
var facing_right: bool = true

var death_timer: int = 125
var anim_frame: int = 9
var anim_tick: int = 0
var alpha: float = 1.0
var hit_bottom: bool = false

var x_min = 10.0
var x_max = 540.0
var y_min = 85.0
var y_max = 380.0

@onready var body: AnimatedSprite2D = $Body

func _ready():
	# Fix 3 — set flip once at spawn, never touch again
	body.flip_h = not facing_right
	if position.x < 115 or vy < -3.0:
		vy -= 1.0
	else:
		vy -= 2.0

func _physics_process(_delta):
	_update_timer()
	_update_frame()
	_update_physics()
	_update_alpha()
	_apply()

func _update_timer():
	if position.y > 370.0 or death_timer > 105:
		death_timer -= 1
	if death_timer <= 0:
		queue_free()

func _update_frame():
	# Hold on frame 6 once fish hits bottom
	if position.y >= y_max:
		hit_bottom = true

	if hit_bottom:
		body.frame = 6
		return

	# Fix 1 — advance frame only every 2 ticks
	anim_tick += 1
	if anim_tick < 2:
		return
	anim_tick = 0

	if death_timer > 105:
		anim_frame = 9 - (death_timer - 106) / 2
		anim_frame = clamp(anim_frame, 0, 9)
	else:
		anim_frame = 9

	body.frame = anim_frame

func _update_physics():
	if vx < 0.0:
		vx += 0.03
		if vx > 0.0: vx = 0.0
	elif vx > 0.0:
		vx -= 0.03
		if vx < 0.0: vx = 0.0

	if vy < 2.0:
		vy += 0.025

	position.x += vx / speed_mod * 0.5
	position.y += vy / speed_mod * 0.5
	position.x = clamp(position.x, x_min, x_max)
	position.y = clamp(position.y, y_min, y_max)

func _update_alpha():
	if death_timer < 105:
		alpha -= 0.005
		alpha = max(alpha, 0.0)
	body.modulate.a = alpha

func _apply():
	var prefix = "small"
	match fish_size:
		1: prefix = "medium"
		2: prefix = "large"
	var anim = prefix + "_die"
	if body.sprite_frames.has_animation(anim):
		body.animation = anim
