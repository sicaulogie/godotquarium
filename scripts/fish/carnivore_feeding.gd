class_name CarnivoreFeeding
extends FishFeedingBase
var eat_cooldown: int = 0

func _ready():
	await owner.ready
	fish = get_parent()
	fish.hunger = randi_range(300, 500)
	coin_timer = randi_range(0, COIN_INTERVAL)

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
	return "carnivore"  # uses "carnivore_die" animation5

func _confirm_eat(target: Node2D):
	fish.eat_frame = 0  # ← always reset on actual eat
	_eat_guppy(target)
	eat_cooldown = 40

func _eat_guppy(guppy: Node2D):
	fish.hunger = 800
	fish.eating_timer = 16
	guppy.is_dead = true
	guppy.queue_free()

func _physics_process(_delta):
	if not is_instance_valid(fish):
		return
	super._physics_process(_delta)
	if eat_cooldown > 0:
		eat_cooldown -= 1

func _check_food_collision():
	if fish.hunger >= 500:  # ← don't chase or eat when satisfied
		return
	if eat_approach_cooldown > 0:
		eat_approach_cooldown -= 1
	if eat_cooldown > 0:
		return
	for g in get_tree().get_nodes_in_group("guppies"):
		if not g is Guppy or g.is_dead or g.size != Guppy.Size.SMALL:
			continue
		var cx = fish.position.x + 40.0
		var cy = fish.position.y + 40.0
		var gx = g.position.x
		var gy = g.position.y
		if cx > gx + 5 and cx < gx + 75 and cy > gy + 5 and cy < gy + 75:
			if not g.is_dead:  # extra guard since queue_free is deferred
				_confirm_eat(g)
			return
		if fish.eating_timer == 0 and eat_approach_cooldown == 0:
			if cx > gx - 20 and cx < gx + 100 and cy > gy - 20 and cy < gy + 100:
				fish.eating_timer = 40
				eat_approach_cooldown = 505
