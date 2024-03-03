extends Button

var item = null
onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var labelName = $NameLabel
onready var itemIcon = $ColorRect/ItemIcon

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade", player, "upgrade_character")
	if item == null:
		item = "health"
	labelName.text = UpgradeDB.UPGRADES[item]["displayName"]
	itemIcon.texture = load(UpgradeDB.UPGRADES[item]["icon"])

func _on_ItemOption_pressed():
	emit_signal("selected_upgrade", item)
