extends '../motion.gd'

const JUMP_DURATION = 0.6
const MAX_JUMP_HEIGHT = 65

const BASE_MAX_AIR_SPEED = 300.0

var AIR_ACCELERATION = 1000
var AIR_DECCELERATION = 2000
var AIR_STEERING_POWER = 50

var height = 0.0 setget set_height

var max_air_speed = 0.0
var air_speed = 0.0
var air_velocity = Vector2()
var air_steering = Vector2()

var timer = 0.0


func initialize(speed, velocity):
	air_speed = speed
	max_air_speed = speed if speed > 0.0 else BASE_MAX_AIR_SPEED
	air_velocity = velocity
	

func enter():
	var tween_node = owner.get_node("Tween")
	tween_node.interpolate_method(self, '_animate_jump_height', 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.start()
	timer = 0.0
	
	
func update(delta):
	var input_direction = get_input_direction()
	
	timer += delta
	if timer >= JUMP_DURATION:
		return 'move'
	
	jump(delta, input_direction)	
	owner.animation_switch("idle")


func jump(delta, input_direction):
	if input_direction:
		air_speed += AIR_ACCELERATION * delta
	else:
		air_speed -= AIR_DECCELERATION * delta
	air_speed = clamp(air_speed, 0, max_air_speed)
	
	var target_velocity = air_speed * input_direction.normalized()
	var steering_velocity = (target_velocity - air_velocity).normalized() * AIR_STEERING_POWER
	air_velocity += steering_velocity
	
	owner.move_and_slide(air_velocity)
	owner.emit_signal('position_changed', owner.position)


func _animate_jump_height(progress):
	self.height = pow(sin(progress * PI), 0.7) * MAX_JUMP_HEIGHT


func set_height(value):
	height = value
	owner.get_node('Pivot').position.y = - value
	var shadow_scale = 0.48710 - value / MAX_JUMP_HEIGHT * 0.4
	owner.get_node('Shadow').scale = Vector2(shadow_scale, shadow_scale)