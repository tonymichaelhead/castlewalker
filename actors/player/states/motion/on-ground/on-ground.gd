extends '../motion.gd'

var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed('attack'):
		return 'attack'

	if event.is_action_pressed('magic'):
		return 'casting_fire'

	if event.is_action_pressed('jump'):
		return 'jump'