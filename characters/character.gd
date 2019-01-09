extends KinematicBody2D

# For visualization (probably don't need)
signal speed_updated
signal state_changed

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)

const MAX_WALK_SPEED = 400
const MAX_RUN_SPEED = 700

var speed = 0.0
var max_speed = 0.0

var velocity = Vector2()
	
func _physics_process(delta):
	if input_direction:
		last_move_direction = input_direction
		if speed != max_speed:
			speed = max_speed
	else:
		speed = 0
		
	velocity = input_direction.normalized() * speed
	move_and_slide(velocity)
	
#	For reference, for handling collisions manually
#	var motion = input_direction.normalized() * speed * delta
#	move_and_collide(motion)
	
	# Instant movement
	
	# Two approaches to collisions