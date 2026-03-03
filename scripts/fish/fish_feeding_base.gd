class_name FishFeedingBase
extends Node2D

var fish: Node2D
var hunger_tick: int = 0
var coin_timer: int = 0

const HUNGER_DEAD = -499
const COIN_INTERVAL = 800
const DeadFishScene = preload("res://scenes/dead_fish.tscn")
const CoinScene = preload("res://scenes/coin.tscn")
var pending_target: Node2D = null
var eat_windup_timer: int = 0
const EAT_WINDUP_FRAMES = 2
var eat_approach_cooldown: int = 0

func _ready():
	await owner.ready
	fish = get_parent()
	coin_timer = randi_range(0, COIN_INTERVAL)

# In fish_feeding_base.gd:
func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	if fish.bought_timer > 0:
		return
	_update_hunger()
	if fish.eating_timer > 0:
		if Engine.get_process_frames() % 2 == 0:
			fish.eating_timer -= 1
	_check_food_collision()
	coin_timer += 1
	if coin_timer >= COIN_INTERVAL:
		coin_timer = 0
		_drop_coin()

# Override to return false if a fish type doesn't use area polling
func _should_poll() -> bool:
	return true

func _poll_feeding_area():
	var area = fish.get_node_or_null("FeedingArea")
	if not area:
		return
	for a in area.get_overlapping_areas():
		if a.is_in_group("food"):
			_on_food_entered(a)
			break

# Make missed-eat safety universal
func _on_eat_missed():
	if is_instance_valid(pending_target):
		pending_target.picked_up = false
	pending_target = null
	_on_eat_missed_extra()

# Override in subclasses that need extra cleanup
func _on_eat_missed_extra():
	pass
	
func _on_food_entered(_area: Area2D):
	pass

func _update_hunger():
	hunger_tick += 1
	if hunger_tick >= 4:
		hunger_tick = 0
		fish.hunger -= 1
	fish.hunger = max(fish.hunger, HUNGER_DEAD)
	if fish.hunger <= HUNGER_DEAD and not fish.is_dead:
		_die()
		
func _check_food_collision():
	if fish.hunger >= 800:
		return
	if eat_approach_cooldown > 0:  # ← add this
		eat_approach_cooldown -= 1
	pass

# Override per fish — how close is close enough to confirm eat
func _get_eat_radius() -> float:
	return 50.0

# Override per fish — what happens when eat is confirmed
func _confirm_eat(_target: Node2D):
	pass

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
