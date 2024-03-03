extends Button

func _on_MainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")
