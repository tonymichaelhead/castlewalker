extends 'on-ground.gd'

var speed = 0.0
var velocity = Vector2()

const MAX_WALK_SPEED = 200
const MAX_RUN_SPEED = 350


func enter(host):
	pass


func handle_input(event):
	if event.is_action_pressed('attack'):
		return ''

	if event.is_action_pressed('magic'):
		return ''

	if event.is_action_pressed('jump'):
		return 'jump'
	
	
func update(host, delta):
	var input_direction = get_input_direction()
	if input_direction:
		return 'move'
	else:
		host.animation_switch("idle")
		
		
func get_input_direction():
	var input_direction = Vector2()
	
	# 8 directions
	input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))
	input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	
#	if input_direction and input_direction != last_move_direction:
#		emit_signal('direction_changed', input_direction)
		
	# Run
#	max_speed = MAX_RUN_SPEED if Input.is_action_pressed('run') else MAX_WALK_SPEED
	
	return input_direction