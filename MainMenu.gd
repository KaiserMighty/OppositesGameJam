extends Control

var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")

func _on_Play_pressed():
	get_tree().change_scene("res://Levels/Autoshooter/World.tscn")


func _on_Tutorials_toggled(button_pressed):
	GlobalVars.tutorials = button_pressed


func _on_Music_toggled(button_pressed):
	AudioServer.set_bus_mute(music_bus, button_pressed)


func _on_MasterVol_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
