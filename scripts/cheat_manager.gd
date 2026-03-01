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
	FishSpawner.spawn_guppy(get_parent())

func _spawn_carnivore():
	FishSpawner.spawn_carnivore(get_parent())

func _spawn_bubbles():
	var count = randi_range(2, 4)
	var bubble_mgr = get_parent().get_node("BubbleManager")
	for i in count:
		bubble_mgr._spawn_bubble()
