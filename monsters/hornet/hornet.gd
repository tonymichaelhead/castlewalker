extends '../steering-monster.gd'

enum STATES { IDLE, FOLLOW, RETURN, ATTACK, ATTACK_COOLDOWN, STAGGER, DIE }

export(float) var knockback = 10
const STAGGER_DURATION = 0.4
const ATTACK_COOLDOWN_DURATION = 0.6

export(float) var FOLLOW_RANGE = 300.0
export(float) var MAX_FLY_SPEED = 300.0

const BUMP_DISTANCE = 60
const BUMP_DURATION = 0.2
const MAX_BUMP_HEIGHT = 50

func initialize(target_actor):
	.initialize(target_actor)
	$Timer.connect('timeout', self, '_on_Timer_timeout')
	$Tween.connect('tween_completed', self, '_on_tween_completed')
	$Health.connect('health_changed', self, '_on_Health_health_changed')
	$AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')
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
			pass
		STAGGER:
			$Tween.interpolate_property(self, 'position', position, position + knockback * -knockback_direction, STAGGER_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
			$Tween.start()
			
			$AnimationPlayer.play('stagger')
		ATTACK:
			set_physics_process(false)
			$AnimationPlayer.stop()
			var bump_direction = (position - target.position).normalized()
			$Tween.interpolate_property(self, 'position', position, position + BUMP_DISTANCE * bump_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		ATTACK_COOLDOWN:
			randomize()
			get_tree().create_timer(ATTACK_COOLDOWN_DURATION).connect('timeout', self, "_change_state", [FOLLOW])
		DIE: queue_free()
	state = new_state
	
	
func _physics_process(delta):
	var current_state = state
	
	update_sprite_direction()
	
	match current_state:
		IDLE:
			if position.distance_to(target.position) < FOLLOW_RANGE:
				_change_state(FOLLOW)
		FOLLOW:
			if position.distance_to(target.position) > FOLLOW_RANGE:
				_change_state(RETURN)
			
			velocity = follow(velocity, target.position, MAX_FLY_SPEED)
			move_and_slide(velocity)
			
			if get_slide_count() == 0:
				return
			var body = get_slide_collision(0).collider
			if body.is_in_group('character'):
				_change_state(ATTACK)
				
		RETURN:
			velocity = arrive_to(velocity, spawn_position)
			move_and_slide(velocity)
	
			if position.distance_to(spawn_position) < ARRIVE_DISTANCE:
				_change_state(IDLE)


func update_sprite_direction():
	if velocity.x < 0:
		get_node("BodyPivot/Body").set_flip_h(true)
	else:
		get_node("BodyPivot/Body").set_flip_h(false)
		

func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state(DIE)
	else:
		_change_state(STAGGER)
		
func _on_tween_completed(object, key):
	_change_state(ATTACK_COOLDOWN)