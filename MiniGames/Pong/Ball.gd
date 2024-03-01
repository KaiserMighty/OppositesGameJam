extends KinematicBody2D

const SPEED = 300.0
const BOOST = 25.0
var direction = Vector2()
var currentSpeed

func _ready():
	currentSpeed = SPEED
	var screen = get_viewport_rect().size
	position.x = screen.x/2
	position.y = screen.y/2
	
	direction = Vector2(1, rand_range(-2, 2))
	direction = direction.normalized() * SPEED

func _physics_process(delta):
	var collision = move_and_collide(direction*delta)
	if collision:
		direction = direction.normalized() * currentSpeed
		direction = direction.bounce(collision.normal)
		currentSpeed = currentSpeed + BOOST
