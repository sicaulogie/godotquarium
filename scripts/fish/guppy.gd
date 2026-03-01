class_name Guppy
extends FishBase

enum Size { SMALL = 0, MEDIUM = 1, LARGE = 2, KING = 3 }

# Guppy-only state
var size: int = Size.SMALL
var food_ate: int = 0
var food_needed_to_grow: int = 0

# Growth animation
var growth_timer: int = 0
var growth_transition_timer: int = 0
var is_king_transition: bool = false
var was_hungry_at_transition: bool = false

# Eating animation
var eating_timer: int = 0
var eat_frame: int = 0
var was_eating: bool = false

# Entry animation
var bought_timer: int = 0
var entry_vy: float = 0.0

func _ready():
	super._ready()  # runs FishBase._ready() for shared init
