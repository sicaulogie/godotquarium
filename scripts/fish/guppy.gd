extends Node2D

enum Size { SMALL = 0, MEDIUM = 1, LARGE = 2, CROWNED = 3 }

# Core state
var hunger: int = 0
var size: int = Size.SMALL
var food_ate: int = 0
var food_needed_to_grow: int = 0

# Movement
var vx: float = 0.1
var vy: float = 0.0
var prev_vx: float = 1.0
var speed_mod: float = 1.8
var vx_abs: int = 1
var move_state: int = 0
var special_timer: int = 0
var x_direction: int = 1

# Animation
var turn_timer: int = 0
var eating_timer: int = 0
var growth_timer: int = 0
var swim_frame_counter: float = 0.0
var anim_frame_index: int = 0
var eat_frame: int = 0
var turn_tick: int = 0 

# Hunger
var hungry_timer: int = 0
var was_hungry: bool = false
var hunger_anim_timer: int = 0
var was_eating: bool = false

# Tank bounds
var x_min: float = 10.0   # was 20
var x_max: float = 540.0  # was 620
var y_min: float = 95.0   # was 80
var y_max: float = 370.0  # was 420

func _ready():
	if randi() % 2 == 0:
		vx = randf_range(-2.0, -0.5)
		prev_vx = -1.0
	else:
		vx = randf_range(0.5, 2.0)
		prev_vx = 1.0
	food_needed_to_grow = randi_range(4, 6)
	x_direction = 1
	move_state = randi() % 9 + 1
	special_timer = randi() % 40
