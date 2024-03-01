extends CanvasLayer

func change_scene(target: String) -> void:
	#$AnimationPlayer.play("Open")
	#yield($AnimationPlayer, "animation_finished")
	#get_tree().change_scene(target)
	get_tree().change_scene("res://MainMenu.tscn")
	#$AnimationPlayer.play("Open")
