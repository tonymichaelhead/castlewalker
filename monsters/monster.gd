extends KinematicBody2D

enum STATES { IDLE, ROAM, RETURN, SPOT, FOLLOW, STAGGER, ATTACK, ATTACK_COOLDOWN, DIE, DEAD }
var state = null

var has_target = false
var target_position = Vector2()

var velocity = Vector2()
const MASS = 1.4

const FOLLOW_RANGE = 300.0
export(float) var max_follow_speed = 200.0
export(float) var max_roam_speed = 125.0

const ARRIVE_DISTANCE = 3.0
const SLOW_RADIUS = 200

const ROAM_RADIUS = 100.0
var roam_target_position = Vector2()
var roam_slow_radius = 0.0

var spawn_position = Vector2()


func _ready():
	spawn_position = position
#	var target_node = get_tree().get_root().get_node('Level/YSort/Player') # Alternate implementation of below line
	_change_state(IDLE)
	$Timer.connect('timeout', self, '_on_Timer_timeout')
	
	var target_node = $'/root/Level/YSort/Player'
	
	if not target_node:
		print('Missing target node on %s' % get_path())
		return
	target_node.connect('position_changed', self, '_on_target_position_changed')
	target_node.connect('died', self, '_on_target_died')
	has_target = true


func follow(target_position, max_speed):
	var desired_velocity = (target_position - position).normalized() * max_speed
	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return position.distance_to(target_position)


func arrive_to(target_position, slow_radius, max_speed):
	var desired_velocity = (target_position - position).normalized() * max_speed
	var distance_to_target = position.distance_to(target_position)
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * 0.75 + 0.25
		
	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return distance_to_target


func _change_state(new_state):
	match state:
		IDLE:
			$Timer.stop()
		
	match new_state:
		IDLE:
			randomize()
			var random_time = randf() * 2.0 + 1.0
			$Timer.wait_time = random_time
			$Timer.start()
		ROAM:
			randomize()
			var random_angle = randf() * PI * 2
			randomize()
			var random_radius = randf() * ROAM_RADIUS * 0.5 + 0.5 * ROAM_RADIUS
			roam_target_position = spawn_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
			roam_slow_radius = spawn_position.distance_to(roam_target_position) / 2
	state = new_state
	
	
func _physics_process(delta):
	var current_state = state
	match current_state:
		IDLE:
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(FOLLOW)
		ROAM:
			var distance_to_target = arrive_to(roam_target_position, roam_slow_radius, max_roam_speed)
			move_and_slide(velocity)
			
			if distance_to_target < ARRIVE_DISTANCE:
				_change_state(IDLE)
			elif position.distance_to(target_position) < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(FOLLOW)
		FOLLOW:
			var distance_to_target = follow(target_position, max_follow_speed)
			move_and_slide(velocity)
			if distance_to_target > FOLLOW_RANGE:
				_change_state(RETURN)
		RETURN:
			var distance_to_target = arrive_to(spawn_position, SLOW_RADIUS, max_roam_speed)
			move_and_slide(velocity)
			if distance_to_target < ARRIVE_DISTANCE:
				_change_state(IDLE)
			elif position.distance_to(target_position) < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(FOLLOW)

func _on_target_position_changed(new_position):
	target_position = new_position


func _on_target_died(new_position):
	target_position = Vector2()
	has_target = false
	_change_state(RETURN)

func _on_Timer_timeout():
	_change_state(ROAM)