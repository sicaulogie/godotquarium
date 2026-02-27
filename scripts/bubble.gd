extends Node2D

var bubble_type: int = 0
var vy: float = 2.0
var shake_offset: int = 0

@onready var sprite: Sprite2D = $Sprite

const SPEEDS = [2.0, 2.5, 3.0, 3.2, 2.3, 2.8]

func _ready():
	# Pick type 0-2 (re-roll if 3, matching original logic)
	bubble_type = randi() % 4
	if bubble_type == 3:
		bubble_type = randi() % 4
	sprite.frame = bubble_type

	# Pick speed
	vy = SPEEDS[randi() % 6]

	# Additive blend — makes black transparent, no PNG editing needed
	sprite.material = CanvasItemMaterial.new()
	sprite.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

func _physics_process(_delta):
	shake_offset = randi() % 2
	sprite.offset.x = shake_offset  # visual wobble only
	position.y -= vy * 0.5
