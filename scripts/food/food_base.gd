extends Node2D

var food_type: int = 0
var exotic_food_type: int = 0
var picked_up: bool = false
var cant_eat_timer: int = 5  				# from Food.cpp constructor

											# Internal variables matching Food.cpp
var xd: float = 0.0
var yd: float = 0.0
var anim_counter: int = 0       			# m0x178
var anim_speed: int = 3         			# m0x17c, randomized 3-4
var fade_timer: int = 0         			# m0x180
var fall_speed: float = 1.5     			# from Food.cpp mYD += 1.5

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	add_to_group("food")          			# Food root node joins group
	$FoodArea.add_to_group("food") 			# FoodArea also joins group
	xd = position.x
	yd = position.y
	anim_speed = randi_range(6, 8)
	fade_timer = 0  						# make sure this starts at 0
	#cant_eat_timer = 5
	sprite.pause()
	sprite.play(get_animation_name())

func _physics_process(_delta):
	if cant_eat_timer > 0:
		cant_eat_timer -= 1

	if fade_timer > 0:						# Fade out timer — from Food.cpp m0x180
		fade_timer -= 1						# Fade alpha like Food.cpp Draw()
		modulate.a = fade_timer * 1.0 / 15.0
		if fade_timer == 0:
			queue_free()
		return

	_update_position()
	_update_animation()
	_check_bottom()

	position = Vector2(xd, yd)

func _update_position():
	if not picked_up:						# Constant fall at 1.5 per tick — from Food.cpp
		yd += 0.75							# Scale for 60fps (original was 30fps)
		xd = clamp(xd, 20.0, 550.0)			# forces food to drop within boundary
		
func _update_animation():					# From Food.cpp m0x178 counter
	anim_counter += 1
	if anim_counter > anim_speed * 10 - 1:
		anim_counter = 0
	sprite.frame = anim_counter / anim_speed

func _check_bottom():						# From Food.cpp — food fades at bottom, star potion explodes
	if yd > 410.0:
		if food_type == 3:
			_explode()
		elif fade_timer < 1:
			fade_timer = 15  # start fade

func _explode():							# Star potion explosion — sound and particles handled by board later
	queue_free()

func get_animation_name() -> String:
	match food_type:
		0: return "food_base"
		1: return "food_pellet"
		2: return "food_capsule"
		_: return "food_base"
