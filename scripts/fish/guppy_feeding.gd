class_name GuppyFeeding
extends FishFeedingBase

const DEBUG_FOOD_NEEDED_TO_GROW = -1

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(300, 500)
	if DEBUG_FOOD_NEEDED_TO_GROW == -1:
		fish.food_needed_to_grow = randi_range(4, 6)
	else:
		fish.food_needed_to_grow = DEBUG_FOOD_NEEDED_TO_GROW
	coin_timer = randi_range(0, COIN_INTERVAL)

# Override — guppy coin type depends on size
func _drop_coin():
	if fish.size == 0:
		return
	var coin = CoinScene.instantiate()
	coin.position = fish.position + Vector2(20, 0)
	match fish.size:
		1: coin.coin_type = 0  # silver — medium, small guppy does not drop coins
		2: coin.coin_type = 1  # gold — large
		3: coin.coin_type = 3  # diamond — king
		_: return              # small fish don't drop coins
	fish.get_parent().add_child(coin)

# Override — guppy death sprite uses current size
func _get_dead_fish_size() -> int:
	return fish.size

func _confirm_eat(target: Node2D):
	_eat_food(target)
	target.queue_free()

func _eat_food(food: Node2D):
	var hungry_before = fish.hunger < 0
	fish.was_hungry = hungry_before
	fish.hunger_anim_timer = 0
	match food.food_type:
		0:
			fish.food_ate += 1
			fish.hunger += 500
			fish.hunger = min(fish.hunger, 800)
		1:
			fish.food_ate += 2
			fish.hunger += 700
			fish.hunger = min(fish.hunger, 1000)
		2:
			fish.food_ate += 3
			fish.hunger += 1100
			fish.hunger = min(fish.hunger, 1400)
	fish.eating_timer = 16
	_check_growth(hungry_before)

func _check_growth(hungry_before: bool = false):
	if fish.size < 2 and fish.food_ate >= fish.food_needed_to_grow:
		fish.size += 1
		fish.food_ate = 0
		fish.growth_timer = 20
		fish.is_king_transition = false
		return
	elif fish.size == 2 and fish.food_ate >= fish.food_needed_to_grow * 8:
		fish.food_ate = 0
		fish.growth_timer = 0
		fish.growth_transition_timer = 20
		fish.is_king_transition = true
		fish.was_hungry_at_transition = hungry_before
		fish.eating_timer = 0

func _check_food_collision():
	if fish.hunger >= 500:
		return
	if eat_approach_cooldown > 0:
		eat_approach_cooldown -= 1
	for f in get_tree().get_nodes_in_group("food"):
		if not f is FoodBase or f.picked_up or f.cant_eat_timer > 0:
			continue
		var cx = fish.position.x + 40.0
		var cy = fish.position.y + 40.0
		var fx = f.position.x
		var fy = f.position.y
		if cx > fx + 5 and cx < fx + 35 and cy > fy and cy < fy + 35:
			if not f.picked_up:
				f.picked_up = true
				eat_approach_cooldown = 80
				_confirm_eat(f)
			return
		if fish.eating_timer == 0 and eat_approach_cooldown == 0:
			if cx > fx - 10 and cx < fx + 50 and cy > fy - 5 and cy < fy + 40:
				fish.eating_timer = 40
				eat_approach_cooldown = 50
