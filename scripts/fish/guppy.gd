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

func _ready():
	add_to_group("guppies")  # allows carnivore to find guppies
	super._ready()
