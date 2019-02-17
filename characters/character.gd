extends KinematicBody2D

# For visualization (probably don't need)
signal speed_updated
signal state_changed

signal position_changed
signal died

var input_direction = Vector2()
var last_move_direction = Vector2(1, 0)
var sprite_direction = "down"

var knockback_direction = Vector2()
export(float) var knockback_force = 10.0
const KNOCKBACK_DURATION = 0.4

const MAX_WALK_SPEED = 200
const MAX_RUN_SPEED = 350

const BUMP_DURATION = 0.2
const BUMP_DISTANCE = 30
const MAX_BUMP_HEIGHT = 20

const JUMP_DURATION = 0.6
const MAX_JUMP_HEIGHT = 65

var AIR_ACCELERATION = 1000
var AIR_DECCELERATION = 2000
var AIR_STEERING_POWER = 50

var height = 0.0 setget set_height

var max_air_speed = 0.0
var air_speed = 0.0
var air_velocity = Vector2()
var air_steering = Vector2()

var speed = 0.0
var max_speed = 0.0

var fire_scene = preload("res://particles/fiery_cloud/Fireball.tscn")
var fire_count = 0
var fire_direction = Vector2()

var velocity = Vector2()

enum STATES { IDLE, MOVE, BUMP, JUMP, ATTACK, CASTING_FIRE, STAGGER, DIE, DEAD }
var state = null

export(String) var weapon_path = ""
var weapon = null


func _ready():

	$Health.connect("health_changed", self, "_on_Health_health_changed")
	_change_state(IDLE)
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	$Tween.connect('tween_completed', self, '_on_Tween_tween_completed')
	
	if not weapon_path:
		return
	var weapon_node = load(weapon_path).instance()

	$WeaponPivot/WeaponSpawn.add_child(weapon_node)
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)
	weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")
	

func _change_state(new_state):
	match state:
		ATTACK:
			set_physics_process(true)
	
	# Initialize the new state
	match new_state:
		IDLE:
			pass
		MOVE:
			pass
		JUMP:
			air_speed = speed
			max_air_speed = max_speed
			air_velocity = velocity if input_direction else Vector2()
			
			$Tween.interpolate_method(self, '_animate_jump_height', 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		BUMP:
			$AnimationPlayer.stop()
			
			$Tween.interpolate_property(self, 'position', position, position + BUMP_DISTANCE * -last_move_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		ATTACK:
			if not weapon:
				_change_state(IDLE)
				return
			
			weapon.attack()
			$AnimationPlayer.play("idle")
			set_physics_process(false)
		CASTING_FIRE:
			$AnimationPlayer.play('cast_fire')
			cast_fire()
		STAGGER:
			$AnimationPlayer.play('stagger')
			$Tween.interpolate_property(self, 'position', position, position + knockback_force * knockback_direction, KNOCKBACK_DURATION, Tween.TRANS_QUART, Tween.EASE_OUT)
			$Tween.start()
		DIE:
			$CollisionPolygon2D.disabled = true
			set_process_input(false)
			$AnimationPlayer.play('die')
		DEAD:
			emit_signal('died')
			queue_free()
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
		
		emit_signal('position_changed', position)
		if collision_info:
			var collider = collision_info.collider
			if max_speed == MAX_RUN_SPEED and collider.is_in_group('environment'):
				_change_state(BUMP)
	elif state == JUMP:
		jump(delta)
		
		animation_switch("idle")

func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	knockback_direction = (global_position - source.global_position).normalized()
	$Health.take_damage(amount)


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


func jump(delta):
	if input_direction:
		air_speed += AIR_ACCELERATION * delta
	else:
		air_speed -= AIR_DECCELERATION * delta
	air_speed = clamp(air_speed, 0, max_air_speed)
	
	var target_velocity = air_speed * input_direction.normalized()
	var steering_velocity = (target_velocity - air_velocity).normalized() * AIR_STEERING_POWER
	air_velocity += steering_velocity
	
	move_and_slide(air_velocity)


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
	if key == ":position":
		_change_state(IDLE)
	if key == ":_animate_bump_height":
		_change_state(IDLE)
	if key == ":_animate_jump_height":
		_change_state(IDLE)
	

func set_height(value):	
	height = value
	$Pivot.position.y = - value
	var shadow_scale = 0.48710 - value / MAX_JUMP_HEIGHT * 0.4
	$Shadow.scale = Vector2(shadow_scale, shadow_scale)
	

func cast_fire():
	print('start')
	$FireballTimer.start()
	fire_direction = last_move_direction
	process_fire()


func process_fire():
	fire_count += 1
	var new_fire = fire_scene.instance()
#	new_fire.position = global_position + fire_count * last_move_direction * 80.0
	new_fire.position = Vector2() + fire_count * fire_direction * 80.0
	add_child(new_fire)

func _on_FireballTimer_timeout():
	print('timeout')
	process_fire()


func _animate_bump_height(progress):
	self.height = pow(sin(progress * PI), 0.5) * MAX_BUMP_HEIGHT


func _animate_jump_height(progress):
	self.height = pow(sin(progress * PI), 0.7) * MAX_JUMP_HEIGHT


func _on_Weapon_attack_finished():
	_change_state(IDLE)
	

func _on_HitBox_body_entered(body):
	if body.is_in_group('monster'):
		take_damage(body, 2)


func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state(DIE)
	else:
		_change_state(STAGGER)
		

func _on_AnimationPlayer_animation_finished(name):
	print('anim finished ', name)
	if name == 'die':
		_change_state(DEAD)
	if name == 'cast_fire':
		print('cast_fire FINISHED')
		fire_count = 0
		$FireballTimer.stop()
		_change_state(IDLE)