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

var spawn_position = Vector2()
var velocity = Vector2()

var target = null # Actor

func _ready():
	print(global_position)
	set_as_toplevel(true)
	spawn_position = global_position


func initialize(target_actor):	
	if not target_actor:
		print('Missing target node on %s' % get_path())
		return
	target = target_actor
	target_actor.connect('died', self, '_on_target_died')


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


func _on_target_died():
	target = null


