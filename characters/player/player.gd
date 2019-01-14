extends 'res://characters/character.gd'

signal direction_changed

func _input(event):
	if event.is_action_pressed('jump'):
		if not state in [IDLE, MOVE]:
			return
		_change_state(JUMP)


func _physics_process(delta):
	input_direction = Vector2()
	
	# 4 directions (First block for reference)
#	if Input.is_action_pressed('move_up'):
#		input_direction.y = -1
#	elif Input.is_action_pressed('move_down'):
#		input_direction.y = 1
#	if Input.is_action_pressed('move_right'):
#		input_direction.x = 1
#	if Input.is_action_pressed('move_left'):
#		input_direction.x = -1
	
#	input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))
#	if not input_direction.x:
#		input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	
	# 8 directions
	input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))
	input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	
	
	# For the DirectionVisualizer (Maybe won't use)
#	if input_direction and input_direction != last_move_direction:
#		emit_signal('direction', input_direction)
		
	# Run
	max_speed = MAX_RUN_SPEED if Input.is_action_pressed('run') else MAX_WALK_SPEED