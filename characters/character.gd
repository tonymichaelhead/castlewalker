extends KinematicBody2D

# For visualization (probably don't need)
signal speed_updated
signal state_changed

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)
var sprite_direction = "down"

const MAX_WALK_SPEED = 250
const MAX_RUN_SPEED = 500

var speed = 0.0
var max_speed = 0.0

var velocity = Vector2()

enum STATES { IDLE, MOVE }
var state = null

func _ready():
	_change_state(IDLE)

func _change_state(new_state):
	# Initialize the new state
	match new_state:
		IDLE:
			animation_switch("idle")
		MOVE:
			animation_switch("walk")
			
	state = new_state
	
func _physics_process(delta):
	update_direction()
	
	move()
	if state == IDLE:
		pass
	elif state == MOVE:
		pass
	
	
#	For reference, for handling collisions manually
#	var motion = input_direction.normalized() * speed * delta
#	move_and_collide(motion)
	
	# Instant movement
	
	# Two approaches to collisions

func update_direction():
	if input_direction:
		last_move_direction = input_direction
		
func move():
	if input_direction:
		if speed != max_speed:
			speed = max_speed
	else:
		speed = 0
		
	velocity = input_direction.normalized() * speed
	move_and_slide(velocity)
	
	sprite_direction_loop()
	
#	if input_direction != Vector2(0, 0):
	if input_direction:
		_change_state(MOVE)
	else:
		_change_state(IDLE)
	
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