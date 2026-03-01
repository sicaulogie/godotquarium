extends Node

var cheat_mode: bool = true  # on by default, disable in later development

const CarnivoreScene = preload("res://scenes/fishes/carnivore.tscn")

func _input(event):
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			# Always available — toggle cheat mode
			KEY_F1:
				cheat_mode = !cheat_mode
				print("Cheat mode: ", "ON" if cheat_mode else "OFF")

			# Always available — non-gameplay cheats
			KEY_B:
				_spawn_bubbles()

			# Gameplay cheats — cheat_mode required
			KEY_1:
				if cheat_mode: _spawn_guppy()
			KEY_2:
				if cheat_mode: _spawn_carnivore()

func _spawn_guppy():
	get_parent()._spawn_fish(randi_range(20, 540), randi_range(105, 370))

func _spawn_carnivore():
	var carnivore = CarnivoreScene.instantiate()
	# Spawn at top like a bought fish — matches guppy entry behavior
	carnivore.position = Vector2(randi_range(60, 500), -40)
	get_parent().add_child(carnivore)

func _spawn_bubbles():
	var count = randi_range(2, 4)
	var bubble_mgr = get_parent().get_node("BubbleManager")
	for i in count:
		bubble_mgr._spawn_bubble()
