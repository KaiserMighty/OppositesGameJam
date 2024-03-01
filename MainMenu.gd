extends Control

func _ready():


func _on_Play_pressed():
	get_tree().change_scene("res://LevelSelect.tscn")


func _on_Tutorials_toggled(button_pressed):
	GlobalVars.tutorials = button_pressed


func _on_Sounds_toggled(button_pressed):
	GlobalVars.sound = button_pressed


func _on_Music_toggled(button_pressed):
	GlobalVars.music = button_pressed
