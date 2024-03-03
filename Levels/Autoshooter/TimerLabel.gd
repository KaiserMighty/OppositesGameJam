extends Label

var time = 0
var timerOn = true

func _process(delta):
	if (timerOn):
		time += delta
	var secs = fmod(time, 60)
	var mins = fmod(time, 60 * 60) / 60
	var timePassed = "%02d : %02d" % [mins, secs]
	text = timePassed
	pass
