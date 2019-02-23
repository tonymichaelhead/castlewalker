extends 'on-ground.gd'

signal direction_changed


func enter(host):
	speed = 0.0
	velocity = Vector2()


func handle_input(event):
	return .handle_input(event)


func update(host, delta):
	var input_direction = get_input_direction(host)
	if not input_direction:
		return 'idle'
	speed = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	var collision_info = move(host, speed, input_direction)
	host.animation_switch("walk")

	owner.emit_signal('position_changed', owner.position)
	if collision_info:
		var collider = collision_info.collider
		if speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
#			_change_state(BUMP) # add bump state
			return 'bump'

# Can be moved to the player controller... check godot final project!
func move(host, speed, direction):
	velocity = direction.normalized() * speed
	host.move_and_slide(velocity, Vector2(), 5, 2)

	var slide_count = host.get_slide_count()
	return host.get_slide_collision(slide_count -1) if slide_count else null
