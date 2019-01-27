tool
extends TextureProgress

export(Color) var COLOR_NORMAL setget set_color_normal
export(Color) var COLOR_FULL
export(Color) var COLOR_LOW

export(float, 0.0, 1.0) var THRESHOLD_LOW = 0.3

var color_current = COLOR_NORMAL

func set_color_normal(value):
	COLOR_NORMAL = value
	modulate = value
	
	
func animate_value(target_value):
	$Tween.interpolate_property(self, "value", value, target_value, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	

func update_color(new_value):
	var new_color
	if new_value == max_value:
		new_color = COLOR_FULL
	elif new_value < THRESHOLD_LOW * max_value:
		new_color = COLOR_LOW
	else:
		new_color = COLOR_NORMAL
		
	if new_color == color_current:
		return
	$Tween.interpolate_property(self, "modulate", color_current, new_color, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	color_current = new_color