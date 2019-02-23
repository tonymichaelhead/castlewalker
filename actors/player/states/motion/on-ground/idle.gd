extends 'on-ground.gd'


func update(host, delta):
	var input_direction = get_input_direction(host)
	if input_direction:
		return 'move'
	else:
		host.animation_switch("idle")