extends Node2D

var fish: Node2D
var hunger_tick: int = 0  # per-fish timer, not global frame counter

const HUNGER_DEAD = -499
const DeadFishScene = preload("res://scenes/dead_fish.tscn")
const CoinScene = preload("res://scenes/money.tscn")
var coin_timer: int = 0
const COIN_INTERVAL = 400  # roughly every 400 ticks

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(600,800)
	coin_timer = randi_range(0, COIN_INTERVAL)
	var area = fish.get_node("FeedingArea")
	area.area_entered.connect(_on_food_entered)

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	_update_hunger()
	coin_timer += 1
	if coin_timer >= COIN_INTERVAL:
		coin_timer = 0
		_drop_coin()

func _drop_coin():
	var coin = CoinScene.instantiate()
	coin.position = fish.position + Vector2(20, 0)
	match fish.size:
		1: coin.coin_type = 0  # COIN_SILVER — medium
		2: coin.coin_type = 1  # COIN_GOLD — large
		_: return  # small fish don't drop coins
	fish.get_parent().add_child(coin)

func _update_hunger():
	hunger_tick += 1
	if hunger_tick >= 2:  # decrement every 2 physics ticks = 30fps equivalent
		hunger_tick = 0
		fish.hunger -= 1
	fish.hunger = max(fish.hunger, HUNGER_DEAD)
	if fish.hunger <= HUNGER_DEAD and not fish.is_dead:
		_die()

func _can_eat_food(food: Node2D) -> bool:
	if food.picked_up or food.cant_eat_timer != 0:
		return false
	return true

func _on_food_entered(area: Area2D):
	if not area.is_in_group("food"):
		return
	var food = area.get_parent()
	if not _can_eat_food(food):
		return
	_eat_food(food)
	food.queue_free()

func _eat_food(food: Node2D):
	match food.food_type:
		0:  # base — brown disc, 1 growth point
			fish.hunger += 500
			fish.hunger = min(fish.hunger, 800)
			fish.food_ate += 1
		1:  # pellet — green cylinder, 2 growth points
			fish.hunger += 700
			fish.hunger = min(fish.hunger, 1000)
			fish.food_ate += 2
		2:  # capsule — red/white capsule, 3 growth points
			fish.hunger += 1000
			fish.hunger = min(fish.hunger, 1400)
			fish.food_ate += 3
	fish.eating_timer = 16
	fish.eat_frame = 0
	_check_growth()

func _check_growth():
	if fish.food_ate >= fish.food_needed_to_grow:
		if fish.size < 2:
			fish.size += 1
			fish.food_ate = 0
			fish.growth_timer = 20
			return
	if fish.food_ate >= fish.food_needed_to_grow * 15:
		if fish.size == 2:
			fish.size = 3
			fish.food_ate = 0
			fish.growth_timer = 20

func _die():
	if fish.is_dead:
		return
	fish.is_dead = true
	# Spawn dead fish at current position with current velocity
	var dead = DeadFishScene.instantiate()
	dead.position = fish.position
	dead.vx = fish.vx
	dead.vy = fish.vy
	dead.speed_mod = fish.speed_mod
	dead.fish_size = fish.size
	dead.facing_right = fish.prev_vx > 0.0
	fish.get_parent().add_child(dead)
	fish.queue_free()
