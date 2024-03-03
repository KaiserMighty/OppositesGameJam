extends Area2D

export var experience = 1

var sprite_one = preload("res://MiniGames/Pong/White.png")
#var sprite_two = preload(textureHere)
#var sprite_three = preload(textureHere)

var target = null
var speed = 0

onready var sprite = $Sprite
onready var collision = $CollisionShape2D
#onready var sound = $sound

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		pass
		#sprite.texture = sprite_two
	else:
		pass
		#sprite.texture = sprite_three

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func collect():
	#sound.play()
	collision.call_deferred("set", "disable", true)
	sprite.visible = false
	return experience
	
#func _on_snd_collected_finished():
	#queue_free()
