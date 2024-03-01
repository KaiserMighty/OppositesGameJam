extends Control


func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")

func _on_Pong_pressed():
	get_tree().change_scene("res://MiniGames/Pong/Pong.tscn")
