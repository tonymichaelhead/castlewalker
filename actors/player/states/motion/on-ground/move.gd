extends 'on-ground.gd'

signal position_changed
signal direction_changed

export(float) var MAX_WALK_SPEED = 200
export(float) var MAX_RUN_SPEED = 350

var speed = 0.0
var velocity = Vector2()


func enter(host):
	return


func handle_input(event):
	if event.is_action_pressed('attack'):
		return 'attack'
	if event.is_action_pressed('magic'):
		return 'casting_fire'
	if event.is_action_pressed('jump'):
		return 'jump'


func update(host, delta):
	var input_direction = get_input_direction(host)
	if not input_direction:
		return 'idle'
	speed = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	var collision_info = move(host, speed, input_direction)
	host.animation_switch("walk")

	emit_signal('position_changed', host.position)
	if collision_info:
		var collider = collision_info.collider
		if speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
#			_change_state(BUMP) # add bump state
			return 'bump'


func get_input_direction(host):
	var input_direction = Vector2()
	
	# 8 directions
	input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))
	input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	#is this necessary?
	if input_direction and owner.look_direction !=input_direction:
		host.last_move_direction = input_direction
		emit_signal('direction_changed', input_direction) # probably don't need?
		owner.look_direction = input_direction
	
	return input_direction


func move(host, speed, direction):
	velocity = direction.normalized() * speed
	host.move_and_slide(velocity, Vector2(), 5, 2)
	
	var slide_count = host.get_slide_count()
	return host.get_slide_collision(slide_count -1) if slide_count else null
