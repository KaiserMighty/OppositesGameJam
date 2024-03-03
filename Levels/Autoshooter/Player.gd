extends KinematicBody2D

#Character
var speed = 100.0
var move = Vector2()
var health = 20.0
var maxHealth = 20.0
var experience = 0
var level = 0
var collectedExperience = 0

#Attacks
var spear = preload("res://Levels/Autoshooter/Spear.tscn")

#AttackNodes
onready var spearTimer = get_node("Attack/SpearTimer")
onready var spearAttackTimer = get_node("Attack/SpearTimer/SpearAttackTimer")
onready var grabArea = get_node("GrabArea/CollisionShape2D")
onready var detectRange = get_node("EnemyDetector/CollisionShape2D")

#Upgrades
var availableOptions = []
var attackHealthUpgrade = 0
var attackSpeedUpgrade = 0
var attackDamageUpgrade = 0
var attackKnockbackUpgrade = 0
var cooldownUpgrade = 0

#Spear
var spearAmmo = 0
var spearBaseAmmo = 1
var spearAttackSpeed = 2

#Enemy
var enemyClose = []

#GUI
onready var experienceBar = get_parent().get_node("Controller/GUILayer/GUI/ExperienceBar")
onready var healthBar = get_parent().get_node("Controller/GUILayer/GUI/HealthBar")
onready var levelLabel = get_parent().get_node("Controller/GUILayer/GUI/ExperienceBar/Level")
onready var levelPanel = get_parent().get_node("Controller/GUILayer/GUI/LevelUp")
onready var upgradeOptions = get_parent().get_node("Controller/GUILayer/GUI/LevelUp/UpgradeOptions")
onready var itemOptions = preload("res://Levels/Autoshooter/ItemOption.tscn")
onready var deathPanel = get_parent().get_node("Controller/GUILayer/GUI/DeathPanel")

#Signal
signal playerDeath

func _ready():
	var screen = get_viewport_rect().size
	position.x = screen.x/2
	position.y = screen.y/2
	
	set_experienceBar(experience, calculate_experiencecap())
	_on_HurtBox_hurt(0, 0, 0)
	
	attack()

func _physics_process(delta):
	var directionV = get_axisV(KEY_W, KEY_S)
	var directionH = get_axisH(KEY_A, KEY_D)
	if directionV:
		move.y = directionV * speed
	else:
		move.y = move_toward(move.y, 0, speed)
	if directionH:
		move.x = directionH * speed
	else:
		move.x = move_toward(move.x, 0, speed)
	move_and_slide(move)

func get_axisV(up, down):
	if Input.is_key_pressed(up) && Input.is_key_pressed(down): return 0
	if Input.is_key_pressed(up): return -1
	elif Input.is_key_pressed(down): return 1

func get_axisH(left, right):
	if Input.is_key_pressed(left) && Input.is_key_pressed(right): return 0
	if Input.is_key_pressed(left): return -1
	elif Input.is_key_pressed(right): return 1


func _on_HurtBox_hurt(damage, _angle, _knockback):
	health -= damage
	healthBar.max_value = maxHealth
	healthBar.value = health
	if health <= 0:
		death()

func attack():
	spearTimer.wait_time = spearAttackSpeed - cooldownUpgrade
	if spearTimer.is_stopped():
		spearTimer.start()

func _on_SpearTimer_timeout():
	spearAmmo += spearBaseAmmo
	spearAttackTimer.start()

func _on_SpearAttackTimer_timeout():
	if spearAmmo > 0:
		var spearAttack = spear.instance()
		spearAttack.position = position
		spearAttack.target = get_random_target()
		spearAttack.health += attackHealthUpgrade
		spearAttack.speed += attackSpeedUpgrade
		spearAttack.damage += attackDamageUpgrade
		spearAttack.knockback += attackKnockbackUpgrade
		add_child(spearAttack)
		spearAmmo -= 1
		if spearAmmo > 0:
			spearAttackTimer.start()
		else:
			spearAttackTimer.stop()
		
func get_random_target():
	if enemyClose.size() > 0:
		return enemyClose[randi() % enemyClose.size()].global_position
	else:
		return Vector2.UP


func _on_EnemyDetector_body_entered(body):
	if not enemyClose.has(body):
		enemyClose.append(body)


func _on_EnemyDetector_body_exited(body):
	if enemyClose.has(body):
		enemyClose.erase(body)


func _on_GrabArea_area_entered(area):
	if area.is_in_group("Loot"):
		area.target = self


func _on_CollectArea_area_entered(area):
	if area.is_in_group("Loot"):
		var gemXP = area.collect()
		calculate_experience(gemXP)
		
func calculate_experience(gemXP):
	var expRequired = calculate_experiencecap()
	collectedExperience += gemXP
	if experience + collectedExperience > expRequired:
		collectedExperience -= expRequired - experience
		level += 1
		experience = 0
		expRequired = calculate_experiencecap()
		levelUp()
	else:
		experience += collectedExperience
		collectedExperience = 0
	set_experienceBar(experience, expRequired)
	
func calculate_experiencecap():
	var XPcap = level
	if level < 20:
		XPcap = level * 5
	elif level < 40:
		XPcap + 95 * (level - 19) * 8
	else:
		XPcap = 255 + (level - 39) * 12
	
	return XPcap

func set_experienceBar(setValue = 1, setMaxValue = 100):
	experienceBar.value = setValue
	experienceBar.max_value = setMaxValue

func levelUp():
	levelLabel.text = str("Level ", level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "rect_position", Vector2(412, 200), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsMax = 3
	while options < optionsMax:
		var optionChoice = itemOptions.instance()
		optionChoice.item = get_random_item()
		upgradeOptions.add_child(optionChoice)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"health":
			health += 20
			health = clamp(health, 0, maxHealth)
		"speed":
			speed += 10
		"maxhp":
			maxHealth += 5
			health += 5
			_on_HurtBox_hurt(0, 0, 0)
		"attackSpeed":
			attackSpeedUpgrade += 10
		"attackDamage":
			attackDamageUpgrade += 5
		"attackHealth":
			attackHealthUpgrade += 1
		"attackKnockback":
			attackKnockbackUpgrade += 25
		"attackAmount":
			spearBaseAmmo += 1
		"cooldown":
			cooldownUpgrade += 0.2
		"magnet":
			grabArea.shape.radius += 10
		"range":
			detectRange.shape.radius += 20
	
	var optionChildren = upgradeOptions.get_children()
	for i in optionChildren:
		i.queue_free()
	availableOptions.clear()
	levelPanel.visible = false
	levelPanel.rect_position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var listDB = []
	for i in UpgradeDB.UPGRADES:
		if not listDB.has(i):
			listDB.append(i)
	if listDB.size() > 0:
		var randomItem = listDB[randi() % listDB.size()]
		availableOptions.append(randomItem)
		return randomItem
	else:
		return null
		
func death():
	deathPanel.visible = true
	get_tree().paused = true
	emit_signal("playerDeath")
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "rect_position", Vector2(412, 200), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
