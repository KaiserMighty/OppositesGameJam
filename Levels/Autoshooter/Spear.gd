extends Area2D

var health = 1
var speed = 100
var damage = 5
var knockback = 100

var target = Vector2.ZERO
var angle = Vector2.ZERO

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var hitSnd = player.get_node("hit")

signal removeFromArray(object)

func _ready():
	set_as_toplevel(true)
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg2rad(90)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle * (player.speed + speed) * delta
	
func enemyHit(charge = 1):
	hitSnd.playing = true
	health -= charge
	if health <= 0:
		emit_signal("removeFromArray", self)
		queue_free()


func _on_Timer_timeout():
	emit_signal("removeFromArray", self)
	queue_free()
