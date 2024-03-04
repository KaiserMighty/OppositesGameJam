extends KinematicBody2D

export var speed = 25.0
export var health = 40.0
export var damageDealt = 8
export var knockbackResist = 7
export var experienceDrop = 12
export var spawnCost = 12

var knockback = Vector2.ZERO
var move = Vector2()
var playerPos
var targetPos
var experience = preload("res://Levels/Autoshooter/Experience.tscn")

onready var player = get_parent().get_parent().get_node("Player")
onready var lootBase = get_parent().get_parent().get_node("Loot")
onready var controller = get_parent().get_parent().get_node("Controller")
onready var hitBox = $HitBox

signal removeFromArray(object)

func _ready():
	hitBox.damage = damageDealt

func _physics_process(delta):
	playerPos = player.position
	knockback = knockback.move_toward(Vector2.ZERO, knockbackResist)
	targetPos = (playerPos - position).normalized()
	
	if position.distance_to(playerPos) > 3:
		move_and_slide(targetPos * speed)
		move_and_slide(knockback)

func death():
	GlobalVars.weakEnemiesKilled += 1
	emit_signal("removeFromArray", self)
	var newExp = experience.instance()
	newExp.global_position = global_position
	newExp.experience = experienceDrop
	lootBase.call_deferred("add_child", newExp)
	controller.spawnPoints += spawnCost
	queue_free()

func _on_HurtBox_hurt(damage, angle, knockbackAmnt):
	health -= damage
	knockback = angle * knockbackAmnt
	if health <= 0:
		death()
