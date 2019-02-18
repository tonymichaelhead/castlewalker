extends 'res://actors/actor.gd'

signal direction_changed

func _input(event):
	if event.is_action_pressed('attack') and not state in [ATTACK, JUMP]:
		_change_state(ATTACK)
	
	if event.is_action_pressed('magic') and not state in [ATTACK, CASTING_FIRE, JUMP]:
		_change_state(CASTING_FIRE)
		
	if event.is_action_pressed('jump'):
		if not state in [IDLE, MOVE]:
			return
		_change_state(JUMP)


func _physics_process(delta):
	input_direction = Vector2()
	
	# 8 directions
	input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))
	input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	
	if input_direction and input_direction != last_move_direction:
		emit_signal('direction_changed', input_direction)
		
	# Run
	max_speed = MAX_RUN_SPEED if Input.is_action_pressed('run') else MAX_WALK_SPEED