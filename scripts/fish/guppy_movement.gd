extends Node2D

var fish: Node2D
var special_move_timer: int = 0  # mSpecialMovementStateChangeTimer gate

func _ready(): #initialize the scene
	await owner.ready # tells this script to "pause" and wait until the top-level node of the scene
	fish = get_parent() #looks up one level in the Node hierarchy and assigns that node to the variable fish

func _physics_process(_delta):
#built-in Godot function. Everything inside here happens every single "tick" of the physics engine. 
#The _delta represents the time passed since the last frame (useful for smooth movement).
	if not is_instance_valid(fish):
		return #safety check. If the fish was deleted, stops the script immediately
	_update_state_timer()
	#calls a custom function that increments the fish's internal clocks

	# From Fish.cpp Hungry() line 969 — only chase food when hunger < 500
	if fish.hunger < 500:
		var nearest_food = _find_nearest_food() 
		#look for nearby food and stores the closeset one in nearest_food variable
		if nearest_food:
			_hungry_behavior(nearest_food) #turns on hungry behavior when found food
		else:
			_apply_movement_state() #default movement state
	else:
		_apply_movement_state()

	#run functions to check respective conditions
	_decelerate_near_walls() 
	_check_wall_collision()
	_detect_direction_change()
	_apply_velocity()

func _update_state_timer():
	# keeps track of time for movement logic. This is called every frame inside _physics_process
	fish.special_timer += 1
	# Increments the special_timer (which corresponds to mSpecialMovementStateChangeTimer 
	# from the original C++ code). This is the "pulse" timer used to trigger physics changes 
	# like the 40-frame friction pulse
	fish.move_state_timer += 1 
	#Increments a second timer to decide if the fish should change its swimming behavior
	if fish.move_state_timer > 20: # change its mind every 20 frame to avoid constant changing
		fish.move_state_timer = 0 # reset stage change timer
		if randi() % 10 == 0: # 10% chance fish switch states
			fish.move_state = randi() % 9 + 1  # pick a number between 1-9 instead of 0-8

func _hungry_behavior(food: Node2D): # From Fish.cpp HungryBehavior() — gated behind special timer > 2
	fish.special_timer += 1 # Increments the "pulse" timer

	# If only 1 or 2 frames have passed, don't do anything just exit the function
	# ensures hunger logic runs every 3rd frame
	if fish.special_timer <= 2:
		return
	fish.special_timer = 0 #resets gate timer

	# Calculates the center point of the fish since godot places node on top left of sprite
	var center_x = fish.position.x + 40.0
	var center_y = fish.position.y + 40.0
	# Calculates center of food pellet
	var fcx = food.position.x + 20.0
	var fcy = food.position.y + 20.0

	if fish.hunger < 301:
		# Very hungry — from Fish.cpp lines 1128-1158
		if center_x > fcx + 8: #the food is more than 8 pixels away
			if fish.vx > -4.0: fish.vx -= 1.3 # high acceleration, add 1.3 to velocity but less than 4
		elif center_x < fcx - 8:
			if fish.vx < 4.0: fish.vx += 1.3
		elif center_x > fcx + 4: #food is closer between 4 and 8 pixels
			if fish.vx > -4.0: fish.vx -= 0.2 # medium acceleration, add 0.2
		elif center_x < fcx - 4:
			if fish.vx < 4.0: fish.vx += 0.2
		elif center_x > fcx: #fish almost touches food
			if fish.vx > -4.0: fish.vx -= 0.05 # add 0.05 to velocity
		elif center_x < fcx:
			if fish.vx < 4.0: fish.vx += 0.05

		if center_y > fcy + 6: #same as above but vertical
			if fish.vy > -3.0: fish.vy -= 1.0
		elif center_y < fcy - 6:
			if fish.vy < 4.0: fish.vy += 1.3
		elif center_y > fcy:
			if fish.vy > -3.0: fish.vy -= 0.5
		elif center_y < fcy:
			if fish.vy < 4.0: fish.vy += 0.7
	else:
		# Normal hungry — from Fish.cpp lines 1162-1192
		if center_x > fcx + 8:
			if fish.vx > -3.0: fish.vx -= 1.0
		elif center_x < fcx - 8:
			if fish.vx < 3.0: fish.vx += 1.0
		elif center_x > fcx + 4:
			if fish.vx > -3.0: fish.vx -= 0.1
		elif center_x < fcx - 4:
			if fish.vx < 3.0: fish.vx += 0.1
		elif center_x > fcx:
			if fish.vx > -3.0: fish.vx -= 0.05
		elif center_x < fcx:
			if fish.vx < 3.0: fish.vx += 0.05

		if center_y > fcy + 6:
			if fish.vy > -2.0: fish.vy -= 0.6
		elif center_y < fcy - 6:
			if fish.vy < 3.0: fish.vy += 1.0
		elif center_y > fcy:
			if fish.vy > -2.0: fish.vy -= 0.3
		elif center_y < fcy:
			if fish.vy < 3.0: fish.vy += 0.5

	if fish.vx_abs < 5: #checks if the current animation speed is below its cap
		fish.vx_abs += 1 #increases animation speed

func _apply_movement_state():
	# State 123 — clicked behavior, skip for now
	# we don't have player clicking fish yet
	if fish.move_state < 5:
		_apply_state_0_to_4()
	else:
		_apply_state_5_to_9()

func _apply_state_0_to_4():
	match fish.move_state: 
	#tells the script to look at the fish's current move_state and
	#find the matching number below to run the corresponding code
		0:
			# Gentle drift — vy=0.5 downward, vx decelerates to 0
			# yd also drifts up slightly — from Fish.cpp mYD -= 0.25/mSpeedMod
			fish.vy = 0.5 #vertical velocity, positive means downward therefore sinking
			if fish.special_timer > 39: #ensures the horizontal speed only changes once every 40 frames
				fish.special_timer = 0 #resets timer
				if fish.vx < -0.5: fish.vx += 0.5
				elif fish.vx > 0.5: fish.vx -= 0.5
				#Horizontal Friction, checks if the fish is moving left or right,change closer to 0
				fish.vx_abs = int(abs(fish.vx)) #Updates the tail animation speed
			fish.position.y -= 0.25 / fish.speed_mod #buoyancy prevents the fish from sinking too fast

		1:
			# Swim right, drift up
			fish.vy = -0.5 #swiming up
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < 1.0: fish.vx += 1.0 #modify fish speed to around 1
				elif fish.vx > 1.0: fish.vx -= 1.0
				fish.vx_abs = int(abs(fish.vx))
			fish.position.y -= 0.5 / fish.speed_mod #higher buoyancy swimming up

		2:
			# Swim left, drift up
			fish.vy = -0.5
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < -1.0: fish.vx += 1.0
				elif fish.vx > -1.0: fish.vx -= 1.0
				fish.vx_abs = int(abs(fish.vx))
			fish.position.y -= 0.5 / fish.speed_mod

		3:
			# Swim left, dive down — auto-switch to state 0 below y=240
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < -1.0: fish.vx += 1.0
				elif fish.vx > -1.0: fish.vx -= 1.0 #horizontal speed close to -1 (left)
				if fish.vy < 3.0: fish.vy += 1.0
				elif fish.vy > 3.0: fish.vy -= 1.0 #vertical speed close to 3
				#if hotizontal speed <5,vertical>=4 and too far left
				if fish.vx_abs < 5: #decrease tail speed when it's fast
					if fish.vy >= 4.0: #increases tail speed when it's slow
						if fish.position.y > 240: #state 0 near bottom
							fish.move_state = 0
					else:
						fish.vx_abs += 1
				else:
					fish.vx_abs -= 1	
			if fish.position.y > 240: #state 0 near bottom
				fish.move_state = 0

		4:
			# Swim right, dive down — auto-switch to state 0 below y=240
			if fish.special_timer > 39:
				fish.special_timer = 0
				if fish.vx < 1.0: fish.vx += 1.0
				elif fish.vx > 1.0: fish.vx -= 1.0
				if fish.vy < 3.0: fish.vy += 1.0
				elif fish.vy > 3.0: fish.vy -= 1.0
				if fish.vx_abs < 5:
					if fish.vy >= 4.0:
						if fish.position.y > 240:
							fish.move_state = 0
					else:
						fish.vx_abs += 1
				else:
					fish.vx_abs -= 1
			if fish.position.y > 240:
				fish.move_state = 0

func _apply_state_5_to_9():
	# Zigzag pattern — bounces between x=175 and x=250
	# vy depends on vertical position
	if fish.position.y >= 115.0: #Checks if the fish is in the middle or bottom of the tank
		fish.vy = -0.5
	else:
		fish.vy = -0.1

	if fish.special_timer > 39:
		fish.special_timer = 0
		if fish.x_direction == 1:
			if fish.vx < 0.0: fish.vx += 2.0
			else: fish.vx += 1.0
			fish.vx_abs = int(abs(fish.vx))
			if fish.position.x > 250.0:
				fish.x_direction = -1
				fish.vx -= 2.0
		elif fish.x_direction == -1:
			if fish.vx > 0.0: fish.vx -= 2.0
			else: fish.vx -= 1.0
			fish.vx_abs = int(abs(fish.vx))
			if fish.position.x < 175.0:
				fish.x_direction = 1
				fish.vx += 2.0

func _find_nearest_food() -> Node2D:
	# From Fish.cpp FindNearestFood() — NO distance limit, always finds nearest
	var food_nodes = get_tree().get_nodes_in_group("food")
	var nearest = null
	var nearest_dist = INF
	for f in food_nodes:
		if f.get("cant_eat_timer") != null and f.cant_eat_timer > 0:
			continue
		if f.get("picked_up") != null and f.picked_up:
			continue
		var d = fish.position.distance_to(f.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = f
	return nearest

func _decelerate_near_walls():
	# From Fish.cpp lines 514-517 — only decelerate near right and left walls
	if fish.position.x > fish.x_max - 5 and fish.vx > 0.1:
		fish.vx -= 0.1
	if fish.position.x < 15 and fish.vx < -0.1:
		fish.vx += 0.1

func _check_wall_collision():
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)

	var hit_left = fish.position.x <= fish.x_min and fish.vx <= 0
	var hit_right = fish.position.x >= fish.x_max and fish.vx >= 0
	var hit_top = fish.position.y <= fish.y_min and fish.vy <= 0
	var hit_bottom = fish.position.y >= fish.y_max and fish.vy >= 0

	if hit_left:
		fish.vx = randf_range(0.5, 1.5)
		fish.move_state = [1, 4, 6][randi() % 3]
		fish.special_timer = 40

	if hit_right:
		fish.vx = randf_range(-1.5, -0.5)
		fish.move_state = [2, 3, 5][randi() % 3]
		fish.special_timer = 40

	if hit_top:
		fish.vy = randf_range(0.5, 1.5)

	if hit_bottom:
		fish.vy = randf_range(-1.5, -0.5)

	# Wide buffer zones near walls — prevent re-entering wall zone
	if hit_left or hit_right:
		if fish.position.y < fish.y_min + 80:
			fish.vy = randf_range(0.5, 1.5)
		elif fish.position.y > fish.y_max - 80:
			fish.vy = randf_range(-1.5, -0.5)

	# Persistent top/bottom drift correction — independent of side walls
	#if fish.position.y <= fish.y_min + 10 and fish.vy < 0:
		#fish.vy = randf_range(0.5, 1.0)
	if fish.position.y < fish.y_min + 80:
		fish.vy = randf_range(0.5, 1.5)
	if fish.position.y >= fish.y_max - 10 and fish.vy > 0:
		fish.vy = randf_range(-1.0, -0.5)

func _detect_direction_change():
	if fish.prev_vx < 0 and fish.vx > 0:
		fish.turn_timer = -20
	elif fish.prev_vx > 0 and fish.vx < 0:
		fish.turn_timer = 20
	if fish.turn_timer > 0: fish.turn_timer -= 1
	elif fish.turn_timer < 0: fish.turn_timer += 1
	if fish.prev_vx != fish.vx and fish.prev_vx != 0 and fish.vx != 0:
		fish.prev_vx = fish.vx

func _apply_velocity():
	# Scale by 0.5 to match original 30fps timing at 60fps
	#if fish.position.x <= fish.x_min + 5 or fish.position.y <= fish.y_min + 5:
		#print("Corner stuck! pos:", fish.position, " vx:", fish.vx, " vy:", fish.vy, " state:", fish.move_state, " special:", fish.special_timer)
	fish.position.x += (fish.vx / fish.speed_mod) * 0.5
	fish.position.y += (fish.vy / fish.speed_mod) * 0.5
	fish.position.x = clamp(fish.position.x, fish.x_min, fish.x_max)
	fish.position.y = clamp(fish.position.y, fish.y_min, fish.y_max)
