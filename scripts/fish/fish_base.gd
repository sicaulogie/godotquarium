class_name FishBase
extends Node2D

# Core state
var hunger: int = 0
var is_dead: bool = false

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
var turn_tick: int = 0
var swim_frame_counter: float = 0.0
var anim_frame_index: int = 0

# Hunger display
var hungry_timer: int = 0
var was_hungry: bool = false
var hunger_anim_timer: int = 0

# Tank bounds — overridden per fish type
var x_min: float = 20.0
var x_max: float = 540.0
var y_min: float = 95.0
var y_max: float = 370.0

func _ready():
	if randi() % 2 == 0:
		vx = randf_range(-2.0, -0.5)
		prev_vx = -1.0
	else:
		vx = randf_range(0.5, 2.0)
		prev_vx = 1.0
	x_direction = 1
	move_state = randi() % 9 + 1
	special_timer = randi() % 40
