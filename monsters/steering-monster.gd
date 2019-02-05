extends KinematicBody2D

signal died

var knockback_direction = Vector2()

const AVOID_MAX_DISTANCE = 150.0
const AVOID_FORCE = 260.0

export(float) var ARRIVE_DISTANCE = 3.0
export(float) var DEFAULT_SLOW_RADIUS = 200.0
export(float) var DEFAULT_MAX_SPEED = 300.0
export(float) var MASS = 8.0


export(float) var SLOW_RADIUS = 200

var state = null

var has_target = false
var spawn_position = Vector2()
var target_position = Vector2()
var velocity = Vector2()


func _ready():
	spawn_position = position
	
	$Timer.connect('timeout', self, '_on_Timer_timeout')
	$Tween.connect('tween_completed', self, '_on_tween_completed')
	$Health.connect('health_changed', self, '_on_Health_health_changed')
	$AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')
	
	var target_node = $'/root/Level/YSort/Player'
	
	if not target_node:
		print('Missing target node on %s' % get_path())
		return
	target_node.connect('position_changed', self, '_on_target_position_changed')
	target_node.connect('died', self, '_on_target_died')
	has_target = true
	

func follow(velocity, target_position, max_speed):
	var desired_velocity = (target_position - position).normalized() * max_speed
	
	var push = calculate_avoid_force(desired_velocity)
	var steering = (desired_velocity - velocity + push) / MASS
	
	return velocity + steering


func arrive_to(velocity, target_position, slow_radius=DEFAULT_SLOW_RADIUS, max_speed=DEFAULT_MAX_SPEED, avoid=false):
	var desired_velocity = (target_position - position).normalized() * max_speed
	var distance_to_target = position.distance_to(target_position)
	
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * 0.75 + 0.25
	
	var push = calculate_avoid_force(desired_velocity) if avoid else Vector2()
	var steering = (desired_velocity - velocity + push) / MASS
	
	return velocity + steering


func calculate_avoid_force(desired_velocity):
	$RayCast2D.cast_to = desired_velocity.normalized() * AVOID_MAX_DISTANCE
	$RayCast2D.force_raycast_update()
	var push = Vector2()
	if $RayCast2D.is_colliding():
		var push_direction = desired_velocity.normalized().rotated(PI/2.0)
		var point = $RayCast2D.get_collision_point()
		push = push_direction * AVOID_FORCE * (1.0 - position.distance_to(point) / AVOID_MAX_DISTANCE)
	return push

func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	knockback_direction = (source.global_position - global_position).normalized()
	$Health.take_damage(amount)


func _on_target_position_changed(new_position):
	target_position = new_position


func _on_target_died(new_position):
	target_position = Vector2()
	has_target = false


