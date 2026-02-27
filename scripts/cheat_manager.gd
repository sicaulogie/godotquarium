extends Node

func _input(event):
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_spawn_guppy()
			KEY_B:
				_spawn_bubbles()

func _spawn_guppy():
	var tank = get_parent()
	tank._spawn_fish(randi_range(20, 540), randi_range(105, 370))

func _spawn_bubbles():
	var count = randi_range(2, 4)
	var bubble_mgr = get_parent().get_node("BubbleManager")
	for i in count:
		bubble_mgr._spawn_bubble()
