extends Node2D

enum Size { SMALL = 0, MEDIUM = 1, LARGE = 2, KING = 3 }

									# Core state, everything starts from 0
var hunger: int = 0
var size: int = Size.SMALL			#starting growth 0
var food_ate: int = 0				#how much food was eaten
var food_needed_to_grow: int = 0	#target food goal for grow up
var is_dead: bool = false

									# Movement
var vx: float = 0.1					#default horizontal speed
var vy: float = 0.0					#vertical speed
var prev_vx: float = 1.0
									#previous frame horizontal velocity for turn detection and facing direction fallback
									#positive = default facing right, negative = left
var speed_mod: float = 1.8			#speed multiplyer
var vx_abs: int = 1					#horizontal speed to calculate animation
var move_state: int = 0				#current movement state (0-9)
var special_timer: int = 0			#movement state change every 40 frames
var x_direction: int = 1			#Z shape patrolling in 5-9

									# Animation
var turn_timer: int = 0				#lock into turning animation before swimming
var eating_timer: int = 0			#lock into eating animation
var growth_timer: int = 0			#lock into growth animation
var swim_frame_counter: float = 0.0 #calculate which frame of swimming animation to display
var anim_frame_index: int = 0		#determine which frame of sprite is shown
var eat_frame: int = 0				#track eating animation
var turn_tick: int = 0 				#control turning speed


# Hunger
var hungry_timer: int = 0
var was_hungry: bool = false
var hunger_anim_timer: int = 0
var was_eating: bool = false

# Tank bounds: swimming boundaries
var x_min: float = 20.0
var x_max: float = 540.0
var y_min: float = 95.0
var y_max: float = 370.0

func _ready():
	if randi() % 2 == 0:					#1/2 chance which way fish swims first
		vx = randf_range(-2.0, -0.5)		#moving left between 0.5-2.0 speed
		prev_vx = -1.0
	else:
		vx = randf_range(0.5, 2.0)			#moving right
		prev_vx = 1.0
	food_needed_to_grow = randi_range(4, 6)	#random number between 4,5,6 for required growth
	x_direction = 1							#started facing right
	move_state = randi() % 9 + 1			#assign move state 0-9
	special_timer = randi() % 40			#random starting frame
