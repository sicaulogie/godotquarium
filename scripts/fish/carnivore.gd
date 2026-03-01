class_name Carnivore
extends FishBase

# Carnivore-specific bounds — from BiFish::Init()
# y_min = 105, y_max = 360 (tighter than guppy)

var coin_timer: int = 0

# Eating animation
var eating_timer: int = 0
var eat_frame: int = 0

func _ready():
	# Override bounds before super._ready() sets velocity
	y_min = 105.0
	y_max = 360.0
	super._ready()
