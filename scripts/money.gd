extends Node2D

const COIN_SILVER = 0
const COIN_GOLD = 1
const COIN_STAR = 2

const COIN_VALUES = {
	COIN_SILVER: 15,
	COIN_GOLD: 35,
	COIN_STAR: 40,
}

var coin_type: int = COIN_SILVER
var yd: float = 0.0
var vy: float = 1.5          # mVY from constructor
var anim_timer: int = 0      # mAnimationTimer 0→79
var anim_frame: int = 0      # mAnimationFrame
var bottom_timer: int = 0    # m0x19c — how long sitting at bottom
var disappear_timer: int = 0 # mDisappearTimer
var collected: bool = false  # m0x198
var collect_start_x: float = 0.0  # m0x180
var collect_start_y: float = 0.0  # m0x184
var collect_timer: int = 0        # m0x17c

const BOTTOM = 370.0
const SIT_TIMEOUT = 20       # frames before disappear starts

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	add_to_group("coins")
	yd = position.y
	_update_sprite_animation()

func _physics_process(_delta):
	_update_anim_timer()
	if disappear_timer > 0:
		disappear_timer -= 1
		if disappear_timer == 0:
			queue_free()
		return
	if not collected:
		_update_fall()
	else:
		_update_collect()

# --- Animation ---

func _update_anim_timer():
	anim_timer += 1
	if anim_timer > 79:
		anim_timer = 0
	# From original: aVal / 2 % 10 (no pets modifier)
	anim_frame = (anim_timer / 2) % 10
	sprite.frame = anim_frame

func _update_sprite_animation():
	match coin_type:
		COIN_SILVER: sprite.animation = "silver"
		COIN_GOLD:   sprite.animation = "gold"
		COIN_STAR:   sprite.animation = "star"

# --- Falling physics ---

func _update_fall():
	# From original: mYD += 1.5 (no pets, not bonus round)
	yd += vy * 0.5  # halved for 60fps
	if yd > BOTTOM:
		yd = BOTTOM
		bottom_timer += 1
		if bottom_timer >= SIT_TIMEOUT:
			disappear_timer = 5
	position.y = yd

# --- Collection (clicked) ---

func collect():
	if collected or disappear_timer > 0:
		return
	collected = true
	collect_start_x = position.x
	collect_start_y = position.y
	collect_timer = 0

func _update_collect():
	# From original lines 330-344:
	# Coin slides toward x=550, y=30 (top-right corner money counter)
	# Each frame: pos += (target - pos) / 7.0
	collect_timer += 1
	var target_x = 550.0
	var target_y = 30.0

	if position.x < target_x:
		position.x += (target_x - position.x) / 7.0
	elif position.x > target_x:
		position.x -= (position.x - target_x) / 7.0

	if position.y < target_y:
		position.y += (target_y - position.y) / 7.0
	elif position.y > target_y:
		position.y -= (position.y - target_y) / 7.0

	# From original: remove when y < 40
	if position.y < 40:
		_receive_money()
		queue_free()

func _receive_money():
	# Hook this up to your money/score system later
	var value = COIN_VALUES.get(coin_type, 0)
	print("Collected coin worth: ", value)

# --- Input ---
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			collect()
