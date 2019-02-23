extends 'on-ground.gd'


func update(delta):
	var input_direction = get_input_direction()
	if input_direction:
		return 'move'
	else:
		owner.animation_switch("idle")