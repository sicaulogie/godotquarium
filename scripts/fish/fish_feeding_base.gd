class_name FishFeedingBase
extends Node2D

var fish: Node2D
var hunger_tick: int = 0
var coin_timer: int = 0

const HUNGER_DEAD = -499
const COIN_INTERVAL = 400
const DeadFishScene = preload("res://scenes/dead_fish.tscn")
const CoinScene = preload("res://scenes/coin.tscn")
var pending_target: Node2D = null
var eat_windup_timer: int = 0
const EAT_WINDUP_FRAMES = 8

func _ready():
	await owner.ready
	fish = get_parent()
	coin_timer = randi_range(0, COIN_INTERVAL)

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_hunger()
	_update_pending_eat()
	coin_timer += 1
	if coin_timer >= COIN_INTERVAL:
		coin_timer = 0
		_drop_coin()

func _update_hunger():
	hunger_tick += 1
	if hunger_tick >= 2:
		hunger_tick = 0
		fish.hunger -= 1
	fish.hunger = max(fish.hunger, HUNGER_DEAD)
	if fish.hunger <= HUNGER_DEAD and not fish.is_dead:
		_die()
		
func _update_pending_eat():
	if pending_target == null:
		return
	if not is_instance_valid(pending_target):
		pending_target = null
		return
	eat_windup_timer -= 1
	if eat_windup_timer > 0:
		return
	var hit_radius = _get_eat_radius()
	if fish.position.distance_to(pending_target.position) < hit_radius:
		_confirm_eat(pending_target)
	else:
		_on_eat_missed()
	pending_target = null

# Override per fish — how close is close enough to confirm eat
func _get_eat_radius() -> float:
	return 50.0

# Override per fish — what happens when eat is confirmed
func _confirm_eat(target: Node2D):
	pass

# Override per fish — what happens when fish missed (optional)
func _on_eat_missed():
	fish.eating_timer = 0
	fish.eat_frame = 0

# Override per fish type
func _drop_coin():
	pass

# Override per fish type — return string to use named sprite e.g. "carnivore"
# Return "" to fall back to size-based prefix
func _get_dead_fish_type() -> String:
	return ""

# Override per fish type — return int size for size-based death sprite
# Only used when _get_dead_fish_type() returns ""
func _get_dead_fish_size() -> int:
	return 0

func _die():
	if fish.is_dead:
		return
	fish.is_dead = true
	var dead = DeadFishScene.instantiate()
	dead.position = fish.position
	dead.vx = fish.vx
	dead.vy = fish.vy
	dead.speed_mod = fish.speed_mod
	dead.facing_right = fish.prev_vx > 0.0
	dead.fish_type = _get_dead_fish_type()
	dead.fish_size = _get_dead_fish_size()
	fish.get_parent().add_child(dead)
	fish.queue_free()
