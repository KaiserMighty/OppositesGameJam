extends Button

var item = null
var caller = 0
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var controller = get_tree().get_nodes_in_group("Controller")[0]
onready var labelName = $NameLabel
onready var itemIcon = $ColorRect/ItemIcon
onready var hoverSound = $hover
onready var clickSound = $click

signal selected_upgrade(upgrade)
signal selected_upgrade_monster(upgrade)

func _ready():
	connect("selected_upgrade", player, "select_upgrade")
	connect("selected_upgrade_monster", controller, "selected_upgrade_monster")
	if item == null:
		item = "health"
	if caller == 0:
		labelName.text = UpgradeDB.UPGRADES[item]["displayName"]
		itemIcon.texture = load(UpgradeDB.UPGRADES[item]["icon"])
	else:
		labelName.text = MonsterDB.UPGRADES[item]["displayName"]
		itemIcon.texture = load(MonsterDB.UPGRADES[item]["icon"])

func _on_ItemOption_toggled(button_pressed):
	clickSound.playing = true
	if caller == 0:
		emit_signal("selected_upgrade", item, button_pressed)
	else:
		emit_signal("selected_upgrade_monster", item, button_pressed)

func _on_ItemOption_mouse_entered():
	hoverSound.playing = true
