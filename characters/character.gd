extends KinematicBody2D

# For visualization (probably don't need)
signal speed_updated
signal state_changed

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)
var sprite_direction = "down"

const MAX_WALK_SPEED = 200
const MAX_RUN_SPEED = 350

const BUMP_DURATION = 0.2
const BUMP_DISTANCE = 30
const MAX_BUMP_HEIGHT = 20

var height = 0.0 setget set_height

var speed = 0.0
var max_speed = 0.0

var velocity = Vector2()

enum STATES { IDLE, MOVE, BUMP }
var state = null


func _ready():
	_change_state(IDLE)
	$Tween.connect('tween_completed', self, '_on_Tween_tween_completed')

func _change_state(new_state):
	# Initialize the new state
	match new_state:
		IDLE:
			pass
		MOVE:
			pass
		BUMP:
			$AnimationPlayer.stop()
			
			$Tween.interpolate_property(self, 'position', position, position + BUMP_DISTANCE * -last_move_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
	state = new_state
	
	
func _physics_process(delta):
	update_direction()
	update_sprite_direction()
	
	if state == IDLE:
		if input_direction:
			_change_state(MOVE)
		else:
			animation_switch("idle")
	elif state == MOVE:
		if not input_direction:
			_change_state(IDLE)
			
		var collision_info = move(delta)
		animation_switch("walk")
		
		if collision_info:
			var collider = collision_info.collider
			if max_speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
				_change_state(BUMP)


func update_direction():
	if input_direction:
		last_move_direction = input_direction
		
		
func move(delta):
	if input_direction:
		if speed != max_speed:
			speed = max_speed
	else:
		speed = 0
		
	velocity = input_direction.normalized() * speed
	move_and_slide(velocity, Vector2(), 5, 2)
	
	var slide_count = get_slide_count()
	return get_slide_collision(slide_count -1) if slide_count else null
	
	
func update_sprite_direction():
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
		

func _on_Tween_tween_completed(object, key):
	if key == ":_animate_bump_height":
		_change_state(IDLE)
	

func set_height(value):
	$Pivot.position.y = value
	height = value
	
	
func _animate_bump_height(progress):
	self.height = - pow(sin(progress * PI), 0.5) * MAX_BUMP_HEIGHT
