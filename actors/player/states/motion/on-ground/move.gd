extends 'on-ground.gd'


func enter():
	speed = 0.0
	velocity = Vector2()


func handle_input(event):
	return .handle_input(event)


func update(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return 'idle'
	speed = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	velocity = input_direction.normalized() * speed
	var collision_info = owner.move(velocity)
	owner.animation_switch("walk")
	
	if collision_info:
		var collider = collision_info.collider
		if speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
#			_change_state(BUMP) # add bump state
			return 'bump'
