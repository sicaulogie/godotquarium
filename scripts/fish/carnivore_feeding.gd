class_name CarnivoreFeeding
extends FishFeedingBase

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(400, 500)
	coin_timer = randi_range(0, COIN_INTERVAL)
	var area = fish.get_node("FeedingArea")
	area.area_entered.connect(_on_hit_area_entered)

# Override — carnivore always drops star coin (type 2) from BiFish::DropCoin()
func _drop_coin():
	var coin = CoinScene.instantiate()
	coin.position = fish.position + Vector2(5, 10)
	coin.coin_type = 3
	fish.get_parent().add_child(coin)

# Override — carnivore uses medium death sprite (size 1)
func _get_dead_fish_size() -> int:
	return 1
	
func _get_dead_fish_type() -> String:
	return "carnivore"  # uses "carnivore_die" animation

func _on_hit_area_entered(area: Area2D):
	if not area.is_in_group("guppies") or pending_target != null:
		return
	var guppy = area.get_parent()
	if not guppy is Guppy or guppy.is_dead:
		return
	pending_target = guppy
	eat_windup_timer = EAT_WINDUP_FRAMES
	fish.eating_timer = 16
	fish.eat_frame = 0

func _get_eat_radius() -> float:
	return 60.0

func _confirm_eat(target: Node2D):
	_eat_guppy(target)

func _eat_guppy(guppy: Node2D):
	fish.hunger += 700
	fish.hunger = min(fish.hunger, 1000)
	fish.eating_timer = 16
	fish.eat_frame = 0
	guppy.is_dead = true
	guppy.queue_free()
