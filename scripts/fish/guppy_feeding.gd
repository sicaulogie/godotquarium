class_name GuppyFeeding
extends FishFeedingBase

const DEBUG_FOOD_NEEDED_TO_GROW = -1

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(400, 500)
	if DEBUG_FOOD_NEEDED_TO_GROW == -1:
		fish.food_needed_to_grow = randi_range(4, 6)
	else:
		fish.food_needed_to_grow = DEBUG_FOOD_NEEDED_TO_GROW
	coin_timer = randi_range(0, COIN_INTERVAL)
	var area = fish.get_node("FeedingArea")
	area.area_entered.connect(_on_food_entered)

# Override — guppy coin type depends on size
func _drop_coin():
	var coin = CoinScene.instantiate()
	coin.position = fish.position + Vector2(20, 0)
	match fish.size:
		1: coin.coin_type = 0  # silver — medium
		2: coin.coin_type = 1  # gold — large
		3: coin.coin_type = 3  # diamond — king
		_: return              # small fish don't drop coins
	fish.get_parent().add_child(coin)

# Override — guppy death sprite uses current size
func _get_dead_fish_size() -> int:
	return fish.size

func _can_eat_food(food: Node2D) -> bool:
	if food.picked_up or food.cant_eat_timer != 0:
		return false
	return true

func _on_food_entered(area: Area2D):
	if not area.is_in_group("food"):
		return
	if fish.hunger >= 500:
		return
	var food = area.get_parent()
	if not _can_eat_food(food):
		return
	_eat_food(food)
	food.queue_free()

func _eat_food(food: Node2D):
	var hungry_before = fish.hunger < 0
	fish.was_hungry = hungry_before
	fish.hunger_anim_timer = 0
	match food.food_type:
		0:
			fish.hunger += 500
			fish.hunger = min(fish.hunger, 800)
			fish.food_ate += 1
		1:
			fish.hunger += 700
			fish.hunger = min(fish.hunger, 1000)
			fish.food_ate += 2
		2:
			fish.hunger += 1000
			fish.hunger = min(fish.hunger, 1400)
			fish.food_ate += 3
	fish.eating_timer = 16
	fish.eat_frame = 0
	_check_growth(hungry_before)

func _check_growth(hungry_before: bool = false):
	if fish.food_ate >= fish.food_needed_to_grow:
		if fish.size < 2:
			fish.size += 1
			fish.food_ate = 0
			fish.growth_timer = 20
			fish.is_king_transition = false
			return
	if fish.food_ate >= fish.food_needed_to_grow * 8:
		if fish.size == 2:
			fish.food_ate = 0
			fish.growth_timer = 0
			fish.growth_transition_timer = 20
			fish.is_king_transition = true
			fish.was_hungry_at_transition = hungry_before
			fish.eating_timer = 0
			fish.was_eating = false
