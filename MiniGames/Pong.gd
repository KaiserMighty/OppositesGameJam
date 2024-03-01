extends Node2D

func _ready():
	print("Gang")


func _on_GoalLeft_body_entered(body):
	if body.name == "Ball":
		print("AI Wins")
		get_tree().change_scene("res://LevelSelect.tscn")


func _on_GoalRight_body_entered(body):
	if body.name == "Ball":
		print("Player Wins")
		get_tree().change_scene("res://LevelSelect.tscn")
