extends KinematicBody2D

export var speed = 50.0
export var health = 10.0
export var damageDealt = 1
export var knockbackResist = 2
export var experienceDrop = 1
export var spawnCost = 1

var knockback = Vector2.ZERO
var move = Vector2()
var playerPos
var targetPos
var experience = preload("res://Levels/Autoshooter/Experience.tscn")
var deathAnim = preload("res://Levels/Autoshooter/Death.tscn")

onready var player = get_parent().get_parent().get_node("Player")
onready var lootBase = get_parent().get_parent().get_node("Loot")
onready var controller = get_parent().get_parent().get_node("Controller")
onready var sprite = $Sprite
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
	var enemyDeath = deathAnim.instance()
	enemyDeath.scale = sprite.scale
	enemyDeath.global_position = global_position
	get_parent().call_deferred("add_child", enemyDeath)
	queue_free()

func _on_HurtBox_hurt(damage, angle, knockbackAmnt):
	health -= damage
	knockback = angle * knockbackAmnt
	if health <= 0:
		death()
