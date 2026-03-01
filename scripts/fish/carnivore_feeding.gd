class_name CarnivoreFeeding
extends FishFeedingBase

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(400, 500)
	coin_timer = randi_range(0, COIN_INTERVAL)
	var area = fish.get_node("HitArea")
	area.area_entered.connect(_on_hit_area_entered)

# Override — carnivore always drops star coin (type 2) from BiFish::DropCoin()
func _drop_coin():
	var coin = CoinScene.instantiate()
	coin.position = fish.position + Vector2(5, 10)
	coin.coin_type = 2  # COIN_STAR
	fish.get_parent().add_child(coin)

# Override — carnivore uses medium death sprite (size 1)
func _get_dead_fish_size() -> int:
	return 1

func _on_hit_area_entered(area: Area2D):
	if not area.is_in_group("guppies"):
		return
	var guppy = area.get_parent()
	if not guppy is Guppy or guppy.is_dead:
		return
	_eat_guppy(guppy)

func _eat_guppy(guppy: Guppy):
	# From BiFish::OnFoodAte() — +700 hunger, cap 1000
	fish.hunger += 700
	fish.hunger = min(fish.hunger, 1000)
	# Trigger eat animation
	fish.eating_timer = 16
	fish.eat_frame = 0
	# Kill the guppy through its own feeding script
	var guppy_feeding = guppy.get_node("Feeding")
	if guppy_feeding:
		guppy_feeding._die()
	else:
		guppy.queue_free()
