extends Label

var time = 0
var timerOn = true
var mins = 0
var secs = 0

func _process(delta):
	if (timerOn):
		time += delta
	secs = fmod(time, 60)
	mins = fmod(time, 60 * 60) / 60
	var timePassed = "%02d : %02d" % [mins, secs]
	GlobalVars.timePassed = timePassed
	text = timePassed
