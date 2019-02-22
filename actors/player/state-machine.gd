extends KinematicBody2D

signal state_changed # do i need?
signal direction_changed
signal died

var look_direction = Vector2(1, 0) setget set_look_direction
var last_move_direction = look_direction
var sprite_direction = "down"
var input_direction = Vector2()

var knockback_direction = Vector2()

export(String) var weapon_path = ""
var weapon = null

var current_state = null
# IMPLEMENT!!
#export(bool) var active = false setget set_active
onready var states_map = {
	'idle': $StateMachine/Idle,
	'jump': $StateMachine/Jump,
	'bump': $StateMachine/Bump,
	'move': $StateMachine/Move,
	'attack': $StateMachine/Attack,
	'casting_fire': $StateMachine/CastingFire,
	'stagger': $StateMachine/Stagger,
	'die': $StateMachine/Die,
}

func _ready():
	$Health.connect("health_changed", self, "_on_Health_health_changed")
	
	current_state = $StateMachine/Idle
	_change_state('idle')
	
	if not weapon_path:
		return
	var weapon_node = load(weapon_path).instance()

	$WeaponPivot/WeaponSpawn.add_child(weapon_node)
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)
	
	for state in $StateMachine.get_children():
		state.connect('finished', self, '_change_state')

# IMPLEMENT!
#func set_active(value):
#	active = value
#	set_physics_process(value)
#	set_process_input(value)
#	if not active:
#		states_stack = []
#		current_state = null

	
func _physics_process(delta):
	update_sprite_direction()
	var new_state = current_state.update(self, delta)
	if new_state:
		_change_state(new_state)
		
		
func _input(event):
	var new_state = current_state.handle_input(event)
	if new_state:
		_change_state(new_state)


func _change_state(state_name):
	current_state.exit(self)

	# You can control the flow of states and transfer data between states here
	# It's better than doing it in the individual state objects so they don't get coupled with one another
	if current_state == states_map['die']:
#		set_active(false) # implement
		return
	if state_name == 'jump':
		$StateMachine/Jump.initialize(current_state.speed, current_state.velocity)
		
	current_state = states_map[state_name]
	current_state.enter(self)
	emit_signal('state_changed', current_state.get_name())


func take_damage(source, amount):
	print('taking damage')
	if self.is_a_parent_of(source):
		return
	knockback_direction = (global_position - source.global_position).normalized()
	$Health.take_damage(amount)


func set_dead(value):
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = true
	emit_signal('died')

func update_sprite_direction():
	match last_move_direction:
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
		
		
func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)

func _on_animation_finished(anim_name):
#	if not active:
#		return # Set up active processing stuff. see StateMachine in Godot final example!
	current_state._on_animation_finished(anim_name)
	

func _on_HitBox_body_entered(body):
	if body.is_in_group('monster'):
		take_damage(body, 2)
		
		
func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state('die')
	else:
		_change_state('stagger')
