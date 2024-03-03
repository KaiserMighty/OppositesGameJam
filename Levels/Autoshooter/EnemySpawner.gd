extends Node2D

var enemyScene = preload("res://Levels/Autoshooter/Enemy.tscn")

func _ready():
	$Timer.start()
	
	
func _on_Timer_timeout():
	var enemy = enemyScene.instance()
	add_child(enemy)
	print()
