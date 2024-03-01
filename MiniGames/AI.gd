extends KinematicBody2D

const SPEED = 300.0
var move = Vector2()
onready var ball = get_parent().get_node("Ball")
var racket
var xpos

func _ready():
	var screen = get_viewport_rect().size
	xpos = screen.x - (screen.x/12)
	position.x = screen.x - (screen.x/12)
	position.y = screen.y/2

func _physics_process(delta):
	var direction = get_axis()
	position.x = xpos
	if direction:
		move.y = direction * SPEED
	else:
		move.y = move_toward(move.y, 0, SPEED)
		
	move_and_slide(move)

func get_axis():
	if abs(position.y - ball.position.y) > 20:
		if position.y < ball.position.y:
			return 1
		else:
			return -1
	else:
		return 0

