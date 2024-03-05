extends Control

var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
onready var hoverSound = $hover
onready var clickSound = $click

func _on_Play_pressed():
	clickSound.playing = true
	get_tree().change_scene("res://Levels/Autoshooter/World.tscn")

func _on_MasterVol_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)

func _on_Music_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)

func _on_Play_mouse_entered():
	hoverSound.playing = true
