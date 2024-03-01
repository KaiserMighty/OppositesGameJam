extends KinematicBody2D

const SPEED = 300.0
var move = Vector2()
var xpos

func _ready():
	var screen = get_viewport_rect().size
	position.x = screen.x/12
	position.y = screen.y/2
	xpos = screen.x/12

func _physics_process(delta):
	var direction = get_axis(KEY_W, KEY_S)
	position.x = xpos
	if direction:
		move.y = direction * SPEED
	else:
		move.y = move_toward(move.y, 0, SPEED)
		
	move_and_slide(move)

func get_axis(up, down):
	if Input.is_key_pressed(up): return -1
	elif Input.is_key_pressed(down): return 1
