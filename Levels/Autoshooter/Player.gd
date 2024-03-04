extends KinematicBody2D

#Character
var speed = 140.0
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
onready var levelNavigation = get_parent().get_node("Navigation2D")
onready var lootBase = get_tree().get_nodes_in_group("Loot")[0]
onready var enemyBase = get_tree().get_nodes_in_group("Enemies")[0]
onready var raycasts  = get_node("context_map").get_children()
var velocity = Vector2.ZERO
var steering_force : Vector2 = Vector2.ZERO
var acc = Vector2.ZERO
var new_velocity
var path = []
var loot = []
var eny = []
var target
var targetEnemy = false
var danger_map = [0,0,0,0,0,0,0,0]
var interest_map = []
var context_map = [0,0,0,0,0,0,0,0]
var vector_map = [Vector2(0,-1), Vector2(1,-1), Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(-1,-1)]

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
	loot.clear()
	loot = lootBase.get_children()
	if loot.size() > 0:
		target = loot[loot.size()-1]
		targetEnemy = false
	else:
		eny.clear()
		eny = enemyBase.get_children()
		if eny.size() > 0:
			target = eny[0]
			targetEnemy = true
		else:
			target = self
			targetEnemy = false

	for i in range(raycasts.size()):
		raycasts[i].cast_to = vector_map[i].normalized() * 250

	navigate_path()
	convert_path_to_interest(delta)
	convert_path_to_danger()
	calculate_concept_map()
	convert_context_map_to_direction()
	steer(delta)
	velocity = move_and_slide(velocity * speed)

func steer(delta):
	velocity += acc * delta

func navigate_path():
	path = levelNavigation.get_simple_path(global_position, target.global_position, true)

func convert_path_to_interest(delta) -> void:
	interest_map.clear()
	if path.size() > 1:
		var vector = to_local(path[1])
		var player_interest_vector : Vector2 = vector.normalized()

		if targetEnemy:
			player_interest_vector = player_interest_vector.tangent() * 2 + player_interest_vector
		for v in vector_map:
			var val = v.normalized().dot(player_interest_vector)
			interest_map.push_back(val)

func convert_path_to_danger() -> void:
	danger_map = [0,0,0,0,0,0,0,0]
	for i in range(raycasts.size()):
		var objects_collide = []
		while raycasts[i].is_colliding():
			var rayca : RayCast2D = raycasts[i]
			var collider = rayca.get_collider()
			objects_collide.append(collider)
			raycasts[i].add_exception(collider)
			raycasts[i].force_raycast_update()
			if objects_collide.size() > 0:
				danger_map[i] = 6 * objects_collide.size()
				if i > 0:
					danger_map[i-1] = 4 * objects_collide.size()
				else:
					danger_map[danger_map.size() - 1 ] = 4 * objects_collide.size()
				if i < danger_map.size() - 1:
					danger_map[i + 1] = 4 * objects_collide.size()
				else:
					danger_map[0] = 4 * objects_collide.size()
		for x in objects_collide:
			raycasts[i].remove_exception(x)
		objects_collide.clear()

func calculate_concept_map():
	for i in range(interest_map.size()):
		context_map[i] = interest_map[i] - danger_map[i]

func convert_context_map_to_direction():
	var num = -100
	var index = 0
	for i in range(context_map.size()):
		if context_map[i] > num:
			num = context_map[i]
			index = i
	var non_normalized_new_vel = vector_map[index]
	new_velocity = vector_map[index].normalized()
	velocity = velocity.normalized()
	var non_normalized_acc = (new_velocity - velocity)
	acc = (non_normalized_new_vel - velocity)
	acc = acc * 5

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
			speed += 20
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
		var itemGot = false
		var randomItem
		while not itemGot:
			randomItem = listDB[randi() % listDB.size()]
			if not availableOptions.has(randomItem):
				availableOptions.append(randomItem)
				itemGot = true
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


func _on_DebugTimer_timeout():
	print(danger_map)
