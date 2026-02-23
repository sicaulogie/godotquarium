extends Node2D

# --- Size enum ---
enum Size { SMALL = 0, MEDIUM = 1, LARGE = 2, CROWNED = 3 }

# --- Constants from Fish.cpp ---
const HUNGER_START_MIN = 400
const HUNGER_START_MAX = 600
const HUNGER_HUNGRY_THRESHOLD = 500
const HUNGER_VERY_HUNGRY = 301
const HUNGER_DEAD = -499
const FOOD_NORMAL_RESTORE = 500
const FOOD_CAP_NORMAL = 800

# --- State variables ---
var hunger: int = 0
var food_ate: int = 0
var food_needed_to_grow: int = 0
var size: int = Size.SMALL
var vx: float = 1.0
var vy: float = 0.0
var prev_vx: float = 1.0
var speed_mod: float = 1.8

var eating_timer: int = 0
var turn_timer: int = 0
var growth_timer: int = 0

# Tank bounds (from Fish.cpp Init)
var x_min = 10.0
var x_max = 540.0
var y_min = 95.0
var y_max = 370.0

# --- Node references ---
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var body: AnimatedSprite2D = $Body
@onready var eyes: AnimatedSprite2D = $Eyes

func _ready():
	hunger = randi_range(HUNGER_START_MIN, HUNGER_START_MAX)
	food_needed_to_grow = randi_range(4, 6)
	vx = 1.0 if randf() > 0.5 else -1.0
	prev_vx = vx
	_update_animation()
	$HungerArea.area_entered.connect(_on_food_entered)

func _physics_process(_delta):
	_update_hunger()
	_update_movement()
	_update_timers()
	_update_animation()

# --- Hunger ---
func _update_hunger():
	hunger -= 1
	if hunger <= HUNGER_DEAD:
		queue_free()

# --- Movement ---
func _update_movement():
	if hunger < HUNGER_HUNGRY_THRESHOLD:
		_hungry_movement()
	else:
		_idle_movement()

	position.x += vx / speed_mod
	position.y += vy / speed_mod

	position.x = clamp(position.x, x_min, x_max)
	position.y = clamp(position.y, y_min, y_max)

	if position.x >= x_max or position.x <= x_min:
		_turn()

func _idle_movement():
	vy = sin(Time.get_ticks_msec() * 0.001) * 0.5

func _hungry_movement():
	var food = _find_nearest_food()
	if not food:
		return
	var speed = 4.0 if hunger < HUNGER_VERY_HUNGRY else 3.0
	var dir = (food.global_position - global_position).normalized()
	vx = move_toward(vx, dir.x * speed, 1.3)
	vy = move_toward(vy, dir.y * speed, 1.0)
	if (prev_vx > 0 and vx < 0) or (prev_vx < 0 and vx > 0):
		_turn()

func _turn():
	vx *= -1.0
	if turn_timer == 0:
		turn_timer = 20 if vx > 0 else -20
	prev_vx = vx

# --- Timers ---
func _update_timers():
	if eating_timer > 0:
		eating_timer -= 1
	if turn_timer != 0:
		turn_timer += 1 if turn_timer < 0 else -1
	if growth_timer > 0:
		growth_timer -= 1

# --- Animation ---
func _get_size_prefix() -> String:
	match size:
		Size.SMALL:   return "small"
		Size.MEDIUM:  return "medium"
		Size.LARGE:   return "large"
		Size.CROWNED: return "large"  # reuse large until crowned assets ready
		_:            return "small"

func _update_animation():
	var prefix = _get_size_prefix()
	var state: String

	if turn_timer != 0:
		state = "turn"
	elif eating_timer > 0:
		state = "eat"
	else:
		state = "swim"

	var anim = prefix + "_" + state

	if body.animation != anim:
		body.play(anim)
		if shadow.sprite_frames.has_animation(anim):
			shadow.play(anim)
		if eyes.sprite_frames.has_animation(anim):
			eyes.play(anim)

	# Lock shadow and eyes to body's current frame
	shadow.frame = body.frame
	eyes.frame = body.frame

	var facing_left = vx < 0.0
	body.flip_h = facing_left
	shadow.flip_h = facing_left
	eyes.flip_h = facing_left

# --- Eating ---
func on_food_ate():
	hunger += FOOD_NORMAL_RESTORE
	hunger = min(hunger, FOOD_CAP_NORMAL)
	eating_timer = 10
	food_ate += 1

	if food_ate >= food_needed_to_grow:
		if size < Size.LARGE:
			size += 1
			food_ate = 0
			growth_timer = 10
		elif food_ate >= food_needed_to_grow * 15 and size == Size.LARGE:
			size = Size.CROWNED
			food_ate = 0
			growth_timer = 10

func _find_nearest_food() -> Node2D:
	var food_nodes = get_tree().get_nodes_in_group("food")
	var nearest = null
	var nearest_dist = INF
	for f in food_nodes:
		var d = global_position.distance_to(f.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = f
	return nearest

func _on_food_entered(area: Area2D):
	if area.is_in_group("food"):
		on_food_ate()
		area.get_parent().queue_free()
