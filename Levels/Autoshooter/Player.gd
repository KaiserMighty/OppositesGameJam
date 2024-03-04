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
var selectedOptions = []
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

#AI
onready var retreatTimer = $RetreatTimer
onready var nav = $NavigationAgent2D
onready var navMesh = get_parent().get_node("Navigation2D")
onready var lootBase = get_tree().get_nodes_in_group("Loot")[0]
onready var enemyBase = get_tree().get_nodes_in_group("Enemies")[0]
var velocity: Vector2 = Vector2.ZERO
var path: Array = []
var loot = []
var eny = []
var dangerEny = []
enum {
	KITE,
	RETREAT,
	COLLECT
}
var state = KITE

#GUI
onready var experienceBar = get_parent().get_node("Controller/GUILayer/GUI/ExperienceBar")
onready var healthBar = get_parent().get_node("Controller/GUILayer/GUI/HealthBar")
onready var levelLabel = get_parent().get_node("Controller/GUILayer/GUI/ExperienceBar/Level")
onready var levelPanel = get_parent().get_node("Controller/GUILayer/GUI/LevelUp")
onready var levelUpInstructions = get_parent().get_node("Controller/GUILayer/GUI/LevelUp/UpgradeInstructions")
onready var upgradeOptions = get_parent().get_node("Controller/GUILayer/GUI/LevelUp/UpgradeOptions")
onready var confirmButton = get_parent().get_node("Controller/GUILayer/GUI/LevelUp/ConfirmButton")
onready var itemOptions = preload("res://Levels/Autoshooter/ItemOption.tscn")
onready var deathPanel = get_parent().get_node("Controller/GUILayer/GUI/DeathPanel")
onready var spawnPanel = get_parent().get_node("Controller/GUILayer/GUI/UnitSelect")
onready var controller = get_parent().get_node("Controller")

#Signal
signal playerDeath
signal spawnProtection(state)
signal playerLevelUp

func _ready():
	connect("playerLevelUp", controller, "monsterLevelUp")
	
	GlobalVars.weakEnemiesKilled = 0
	GlobalVars.strongEnemiesKilled = 0
	GlobalVars.tankEnemiesKilled = 0
	GlobalVars.totalUpgrades = 0
	
	set_experienceBar(experience, calculate_experiencecap())
	_on_HurtBox_hurt(0, 0, 0)
	
	attack()

func _physics_process(delta):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var randomnum = rng.randf()
	
	eny.clear()
	eny = enemyBase.get_children()
	if eny.size() == 0:
		state = COLLECT
	else:
		if not state == RETREAT:
			state = KITE
	
	loot.clear()
	loot = lootBase.get_children()
	if loot.size() == 0:
		loot.append(self)
	
	match state:
		KITE:
			move(get_circle_position(randomnum, eny[0]), delta)
		RETREAT:
			print("RETREAT")
			move(dangerEny[0].global_position - self.global_position, delta)
		COLLECT:
			move(loot[0].global_position, delta)
	
func move(target, delta):
	var direction = (target - global_position).normalized() 
	var desired_velocity =  direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	velocity = move_and_slide(velocity)

func get_circle_position(random, target):
	var kill_circle_centre = target.global_position
	var radius = 800
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return Vector2(x, y)

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
	levelUpInstructions.text = "Player will pick 1 of the 3 upgrades you give them"
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "rect_position", Vector2(312, 175), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	spawnPanel.visible = false
	var options = 0
	var optionsMax = 6
	while options < optionsMax:
		var optionChoice = itemOptions.instance()
		optionChoice.item = get_random_item()
		optionChoice.caller = 0
		upgradeOptions.add_child(optionChoice)
		options += 1
	get_tree().paused = true
	
func select_upgrade(upgrade, state):
	if state == true:
		selectedOptions.append(upgrade)
	else:
		selectedOptions.erase(upgrade)
	if selectedOptions.size() == 3:
		confirmButton.disabled = false
	else:
		confirmButton.disabled = true
	
func upgrade_character():
	GlobalVars.totalUpgrades += 1
	var upgrade = selectedOptions[randi() % selectedOptions.size()]
	selectedOptions.clear()
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
	get_tree().paused = false
	calculate_experience(0)
	emit_signal("playerLevelUp")

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
	spawnPanel.visible = false
	deathPanel.visible = true
	emit_signal("playerDeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "rect_position", Vector2(412, 175), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_SpawnProtection_mouse_entered():
	emit_signal("spawnProtection", true)

func _on_SpawnProtection_mouse_exited():
	emit_signal("spawnProtection", false)

func _on_RetreatTimer_timeout():
	state = KITE

func _on_GrabArea_body_entered(body):
	if body.is_in_group("Enemy"):
		state = RETREAT
		dangerEny.append(body)
		retreatTimer.start()

func _on_GrabArea_body_exited(body):
	if body.is_in_group("Enemy"):
		dangerEny.erase(body)
