extends Button

onready var clickSound = $click2

func _on_MainMenu_pressed():
	clickSound.playing = true
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")
