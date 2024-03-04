extends Camera2D

var zoomSpeed = 100
var zoomMargin = .3
var zoomMin = 1
var zoomMax = 4
var zoomPos = Vector2()
var zoomFactor = 1.0

func _process(delta):
	zoom.x = lerp(zoom.x, zoom.x * zoomFactor, zoomSpeed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomFactor, zoomSpeed * delta)
	
	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)

func _input(event):
	if abs(zoomPos.x - get_global_mouse_position().x) > zoomMargin:
		zoomFactor = 1.0
	if abs(zoomPos.y - get_global_mouse_position().y) > zoomMargin:
		zoomFactor = 1.0
	
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoomFactor -= 0.01
				zoomPos = get_global_mouse_position()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoomFactor += 0.01
				zoomPos = get_global_mouse_position()
