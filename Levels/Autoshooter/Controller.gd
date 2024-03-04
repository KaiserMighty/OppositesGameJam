extends Node2D

onready var player = get_tree().get_nodes_in_group("Player")[0]

onready var timeElapsedLabel = get_node("GUILayer/GUI/DeathPanel/ResultLabel/Statistics/TimeElapsed")
onready var weakKillsLabel = get_node("GUILayer/GUI/DeathPanel/ResultLabel/Statistics/WeakKills")
onready var strongKillsLabel = get_node("GUILayer/GUI/DeathPanel/ResultLabel/Statistics/StrongKills")
onready var tankKillsLabel = get_node("GUILayer/GUI/DeathPanel/ResultLabel/Statistics/TankKills")
onready var totalUpgradesLabel = get_node("GUILayer/GUI/DeathPanel/ResultLabel/Statistics/TotalUpgrades")

onready var spawnPointsLabel = get_node("GUILayer/GUI/UnitSelect/HBoxContainer/TextureRect/SpawnPoints")
onready var	spawnCooldownPB = get_node("GUILayer/GUI/UnitSelect/HBoxContainer/CooldownBar")
onready var weakButton = get_node("GUILayer/GUI/UnitSelect/HBoxContainer/SpawnWeak")
onready var strongButton = get_node("GUILayer/GUI/UnitSelect/HBoxContainer/SpawnStrong")
onready var tankButton = get_node("GUILayer/GUI/UnitSelect/HBoxContainer/SpawnTank")

onready var enemyBase = get_parent().get_node("Enemies")
onready var levelPanel = get_node("GUILayer/GUI/LevelUp")
onready var levelUpInstructions = get_node("GUILayer/GUI/LevelUp/UpgradeInstructions")
onready var spawnPanel = get_node("GUILayer/GUI/UnitSelect")
onready var upgradeOptions = get_node("GUILayer/GUI/LevelUp/UpgradeOptions")
onready var confirmButton = get_node("GUILayer/GUI/LevelUp/ConfirmButton")
onready var itemOptions = preload("res://Levels/Autoshooter/ItemOption.tscn")

var enemyScene = preload("res://Levels/Autoshooter/Enemy.tscn")
var strongScene = preload("res://Levels/Autoshooter/EnemyStrong.tscn")
var tankScene = preload("res://Levels/Autoshooter/EnemyTank.tscn")
var selectedEnemy = 0
var spawnReady = false
var ignoreMouse = false
var spawnProtection = false
var monsterUpgrade = false

var availableOptions = []
var selectedOptions = []
var weakHealthUpgrade = 0
var weakDamageUpgrade = 0
var weakKnockbackUpgrade = 0
var weakSpeedUpgrade = 0
var strongHealthUpgrade = 0
var strongDamageUpgrade = 0
var strongKnockbackUpgrade = 0
var strongSpeedUpgrade = 0
var tankHealthUpgrade = 0
var tankDamageUpgrade = 0
var tankKnockbackUpgrade = 0
var tankSpeedUpgrade = 0

var spawnPoints = 4

signal upgrade_confirmed

func _ready():
	connect("upgrade_confirmed", player, "upgrade_character")
	$SpawnCooldown.start()
	
func _process(delta):
	if Input.is_key_pressed(KEY_W):
		position.y -= 4
	if Input.is_key_pressed(KEY_S):
		position.y += 4
	if Input.is_key_pressed(KEY_A):
		position.x -= 4
	if Input.is_key_pressed(KEY_D):
		position.x += 4
	
	spawnCooldownPB.value = 1 - $SpawnCooldown.time_left
	clamp(spawnPoints, 0, 99)
	var spawnPointsUpdate = "%02d" % [spawnPoints]
	spawnPointsLabel.text = spawnPointsUpdate
	if Input.is_action_pressed("click"):
		if ignoreMouse == false:
			if spawnProtection == false:
				spawn(selectedEnemy)

func _on_Player_playerDeath():
	timeElapsedLabel.text = "Time Elapsed - %s" % [GlobalVars.timePassed]
	weakKillsLabel.text = "Weak Enemies - %d" % [GlobalVars.weakEnemiesKilled]
	strongKillsLabel.text = "Strong Enemies - %d" % [GlobalVars.strongEnemiesKilled]
	tankKillsLabel.text = "Tank Enemies - %d" % [GlobalVars.tankEnemiesKilled]
	totalUpgradesLabel.text = "Total Upgrades - %d" % [GlobalVars.totalUpgrades]

func _on_SpawnCooldown_timeout():
	spawnReady = true

func spawn(type):
	if spawnReady:
		match type:
			0:
				pass
			1:
				if spawnPoints >= 1:
					spawnReady = false
					$SpawnCooldown.start()
					var enemy = enemyScene.instance()
					enemy.position = get_global_mouse_position()
					enemy.health += weakHealthUpgrade
					enemy.damageDealt += weakDamageUpgrade
					enemy.knockbackResist += weakKnockbackUpgrade
					enemy.speed += weakSpeedUpgrade
					enemyBase.add_child(enemy)
					spawnPoints -= 1
				else:
					pass
				
			2:
				if spawnPoints >= 4:
					spawnReady = false
					$SpawnCooldown.start()
					var enemy = strongScene.instance()
					enemy.position = get_global_mouse_position()
					enemy.health += strongHealthUpgrade
					enemy.damageDealt += strongDamageUpgrade
					enemy.knockbackResist += strongKnockbackUpgrade
					enemy.speed += strongSpeedUpgrade
					enemyBase.add_child(enemy)
					spawnPoints -= 4
				else:
					pass
			3:
				if spawnPoints >= 12:
					spawnReady = false
					$SpawnCooldown.start()
					var enemy = tankScene.instance()
					enemy.position = get_global_mouse_position()
					enemy.health += tankHealthUpgrade
					enemy.damageDealt += tankDamageUpgrade
					enemy.knockbackResist += tankKnockbackUpgrade
					enemy.speed += tankSpeedUpgrade
					enemyBase.add_child(enemy)
					spawnPoints -= 12
				else:
					pass
	else:
		pass

func monsterLevelUp():
	levelUpInstructions.text = "Pick 2 upgrades for your spawns"
	confirmButton.disabled = true
	monsterUpgrade = true
	var options = 0
	var optionsMax = 6
	while options < optionsMax:
		var optionChoice = itemOptions.instance()
		optionChoice.item = get_random_item()
		optionChoice.caller = 1
		upgradeOptions.add_child(optionChoice)
		options += 1
	get_tree().paused = true
	
func selected_upgrade_monster(upgrade, state):
	if state == true:
		selectedOptions.append(upgrade)
	else:
		selectedOptions.erase(upgrade)
	if selectedOptions.size() == 2:
		confirmButton.disabled = false
	else:
		confirmButton.disabled = true
	
func get_random_item():
	var listDB = []
	for i in MonsterDB.UPGRADES:
		if not listDB.has(i):
			listDB.append(i)
	if listDB.size() > 0:
		var randomItem = listDB[randi() % listDB.size()]
		availableOptions.append(randomItem)
		return randomItem
	else:
		return null

func _on_SpawnWeak_toggled(button_pressed):
	if button_pressed:
		strongButton.pressed = false
		tankButton.pressed = false
		selectedEnemy = 1
	else:
		selectedEnemy = 0

func _on_SpawnStrong_toggled(button_pressed):
	if button_pressed:
		weakButton.pressed = false
		tankButton.pressed = false
		selectedEnemy = 2
	else:
		selectedEnemy = 0

func _on_SpawnTank_toggled(button_pressed):
	if button_pressed:
		strongButton.pressed = false
		weakButton.pressed = false
		selectedEnemy = 3
	else:
		selectedEnemy = 0
	
func _on_Player_spawnProtection(state):
	spawnProtection = state

func _on_UnitSelect_mouse_entered():
	ignoreMouse = true

func _on_UnitSelect_mouse_exited():
	ignoreMouse = false

func _on_ConfirmButton_pressed():
	if monsterUpgrade == true:
		confirmButton.disabled = true
		monsterUpgrade = false
		for i in selectedOptions:
			var upgrade = i
			match upgrade:
				"weakHealth":
					weakHealthUpgrade += 5
				"strongHealth":
					strongHealthUpgrade += 10
				"tankHealth":
					tankHealthUpgrade += 20
				"weakSpeed":
					weakSpeedUpgrade += 10
				"strongSpeed":
					strongSpeedUpgrade += 15
				"tankSpeed":
					tankSpeedUpgrade += 5
				"weakDamage":
					weakDamageUpgrade += 1
				"strongDamage":
					strongDamageUpgrade += 2
				"tankDamage":
					tankDamageUpgrade += 8
				"weakKnockback":
					weakKnockbackUpgrade += 0.5
				"strongKnockback":
					strongKnockbackUpgrade += 0.5
				"tankKnockback":
					tankKnockbackUpgrade += 0.5
		
		selectedOptions.clear()
		var optionChildren = upgradeOptions.get_children()
		for i in optionChildren:
			i.queue_free()
		availableOptions.clear()
		levelPanel.visible = false
		levelPanel.rect_position = Vector2(1600, 175)
		spawnPanel.visible = true
		get_tree().paused = false
		spawnPoints += 4
	else:
		emit_signal("upgrade_confirmed")

func _on_Button_pressed():
	get_node("GUILayer/GUI/Tutorial").visible = false
