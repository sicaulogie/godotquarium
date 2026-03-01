class_name FishFeedingBase
extends Node2D

var fish: Node2D
var hunger_tick: int = 0
var coin_timer: int = 0

const HUNGER_DEAD = -499
const COIN_INTERVAL = 400
const DeadFishScene = preload("res://scenes/dead_fish.tscn")
const CoinScene = preload("res://scenes/coin.tscn")

func _ready():
	await owner.ready
	fish = get_parent()
	coin_timer = randi_range(0, COIN_INTERVAL)

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_hunger()
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

# Override per fish type — different coin types
func _drop_coin():
	pass

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
	dead.fish_size = _get_dead_fish_size()
	fish.get_parent().add_child(dead)
	fish.queue_free()

# Override per fish type — what size sprite to use for death
func _get_dead_fish_size() -> int:
	return 0
