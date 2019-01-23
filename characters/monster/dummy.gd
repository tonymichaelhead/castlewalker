extends KinematicBody2D

signal state_changed
signal direction_changed

var input_direction = Vector2()
var look_direction = Vector2(1, 0)
var last_move_direction = Vector2(1, 0)

var knockback_direction = Vector2()
export(float) var knockback_force = 10.0
const KNOCKBACK_DURATION = 0.4

enum STATES { IDLE, ATTACK, STAGGER }
var state = null

export(String) var weapon_scene_path = ''
var weapon = null


func _ready():
	_change_state(IDLE)
	$Health.connect('health_changed', self, '_on_Health_health_changed')

	if not weapon_scene_path:
		return
	var weapon_instance = load(weapon_scene_path).instance()

	$WeaponPivot/WeaponSpawn.add_child(weapon_instance)
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)
	weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")


func _change_state(new_state):
	# Prevent player from changing direction
	match state:
		ATTACK:
			set_physics_process(true)

	# Initialize the new state
	match new_state:
		IDLE:
			$AnimationPlayer.play('idle')
		ATTACK:
			set_physics_process(false)
			if not weapon:
				print("%s tries to attack but has no weapon" % get_name())
				_change_state(IDLE)
				return

			weapon.attack()
			$AnimationPlayer.play('idle')
		STAGGER:
			$AnimationPlayer.play('stagger')
			$Tween.interpolate_property(self, 'position', position, position + knockback_force * knockback_direction, KNOCKBACK_DURATION, Tween.TRANS_QUART, Tween.EASE_OUT)
			$Tween.start()
	state = new_state
	emit_signal('state_changed', new_state)


func _physics_process(delta):
	if not input_direction:
		return

	last_move_direction = input_direction
	if input_direction.x in [-1, 1]:
		look_direction.x = input_direction.x
		$BodyPivot.set_scale(Vector2(look_direction.x, 1))


func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	knockback_direction = (global_position - source.global_position).normalized()
	$Health.take_damage(amount)


func _on_Weapon_attack_finished():
	_change_state(IDLE)


func _on_Health_health_changed(new_health):
	if new_health == 0:
		queue_free()
	else:
		_change_state(STAGGER)
