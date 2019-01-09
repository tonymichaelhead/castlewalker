extends KinematicBody2D

# For visualization (probably don't need)
signal speed_updated
signal state_changed

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)
var sprite_direction = "down"

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
	
	sprite_direction_loop()
	
	if input_direction != Vector2(0, 0):
		animation_switch("walk")
	else:
		animation_switch("idle")
	
#	For reference, for handling collisions manually
#	var motion = input_direction.normalized() * speed * delta
#	move_and_collide(motion)
	
	# Instant movement
	
	# Two approaches to collisions
	
func sprite_direction_loop():
	match input_direction:
		Vector2(-1, 0):
			sprite_direction = "left"
		Vector2(1, 0):
			sprite_direction = "right"
		Vector2(0, -1):
			sprite_direction = "up"
		Vector2(0, 1):
			sprite_direction = "down"

func animation_switch(animation):
	var new_animation = str(animation, "_", sprite_direction)
	if $AnimationPlayer.current_animation != new_animation:
		$AnimationPlayer.play(new_animation)