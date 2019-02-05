extends '../steering-monster.gd'

enum STATES { IDLE, ROAM, RETURN, SPOT, FOLLOW, STAGGER, ATTACK, ATTACK_COOLDOWN, DIE, DEAD }

export(float) var knockback = 10
const STAGGER_DURATION = 0.4

var last_move_direction = Vector2(1, 0)
const MASS = 1.4

const SPOT_RANGE = 300.0
export(float) var FOLLOW_RANGE = 400.0
export(float) var max_follow_speed = 200.0
export(float) var max_roam_speed = 125.0

const ROAM_RADIUS = 100.0
var roam_target_position = Vector2()
var roam_slow_radius = 0.0

const BUMP_DISTANCE = 60
const BUMP_DURATION = 0.2
const MAX_BUMP_HEIGHT = 50

const ATTACK_COOLDOWN_DURATION = 0.6


func _ready():
	_change_state(IDLE)


func _change_state(new_state):
	match state:
		IDLE:
			$Timer.stop()
		RETURN:
			$RayCast2D.visible = false
		FOLLOW:
			$RayCast2D.visible = false
		ATTACK:
			set_physics_process(true)
		
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
		SPOT:
			$AnimationPlayer.play('spot')
		ATTACK:
			set_physics_process(false)
			$AnimationPlayer.stop()
			var bump_direction = (position - target_position).normalized()
			$Tween.interpolate_property(self, 'position', position, position + BUMP_DISTANCE * bump_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		ATTACK_COOLDOWN:
			randomize()
			get_tree().create_timer(ATTACK_COOLDOWN_DURATION).connect('timeout', self, "_change_state", [FOLLOW])
		STAGGER:
			$Tween.interpolate_property(self, 'position', position, position + knockback * -knockback_direction, STAGGER_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
			$Tween.start()
			
			$AnimationPlayer.play('stagger')
		DIE:
			set_physics_process(false)
			$CollisionPolygon2D.disabled = true
			$Tween.stop(self, '')
			$AnimationPlayer.play('die')
		DEAD:
			queue_free()
		RETURN:
			$RayCast2D.visible = true
		FOLLOW:
			$RayCast2D.visible = true
	state = new_state


func _physics_process(delta):
	var current_state = state
	
	update_sprite_direction()
	
	match current_state:
		IDLE:
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < SPOT_RANGE:
				if not has_target:
					return
				_change_state(SPOT)
		ROAM:
			velocity = arrive_to(velocity, roam_target_position, roam_slow_radius, max_roam_speed)
			move_and_slide(velocity)
			
			if position.distance_to(roam_target_position) < ARRIVE_DISTANCE:
				_change_state(IDLE)
			elif position.distance_to(target_position) < SPOT_RANGE:
				if not has_target:
					return
				_change_state(SPOT)
		RETURN:
			velocity = arrive_to(velocity, spawn_position, SLOW_RADIUS, max_roam_speed, true)
			move_and_slide(velocity)
			if position.distance_to(spawn_position) < ARRIVE_DISTANCE:
				_change_state(IDLE)
			elif position.distance_to(target_position) < SPOT_RANGE:
				if not has_target:
					return
				_change_state(SPOT)
		FOLLOW:
			velocity = follow(velocity, target_position, max_follow_speed)
			move_and_slide(velocity)
			if get_slide_count() != 0:
				var collider = get_slide_collision(0).collider
				if collider.is_in_group('character'):
					_change_state(ATTACK)
			if position.distance_to(target_position) > FOLLOW_RANGE:
				_change_state(RETURN)


func update_sprite_direction():
	if velocity.x < 0:
		get_node("BodyPivot/Body").set_flip_h(true)
	else:
		get_node("BodyPivot/Body").set_flip_h(false)


func _on_Timer_timeout():
	_change_state(ROAM)
	

func _animate_bump_height(progress):
	$BodyPivot.position.y = -pow(sin(progress * PI), 0.4) * MAX_BUMP_HEIGHT


func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state(DIE)
	else:
		_change_state(STAGGER)

	
func _on_tween_completed(object, key):
	_change_state(ATTACK_COOLDOWN)
	

func _on_animation_finished(name):
	if name == 'spot':
		_change_state(FOLLOW)
	if name == 'die':
		_change_state(DEAD)