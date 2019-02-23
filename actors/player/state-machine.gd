extends Node

signal state_changed(current_state)

var current_state = null
# IMPLEMENT!!
#export(bool) var active = false setget set_active
onready var states_map = {
	'idle': $Idle,
	'jump': $Jump,
	'bump': $Bump,
	'move': $Move,
	'attack': $Attack,
	'casting_fire': $CastingFire,
	'stagger': $Stagger,
	'die': $Die,
}

func _ready():
	for state in get_children():
		state.connect('finished', self, '_change_state')


func start():
	current_state.enter()
#	set_active(true) # implement

# IMPLEMENT!
#func set_active(value):
#	active = value
#	set_physics_process(value)
#	set_process_input(value)
#	if not active:
#		states_stack = []
#		current_state = null

	
func _physics_process(delta):
	owner.update_sprite_direction() # this should probably be moved to motion states or something
	var new_state = current_state.update(delta)
	if new_state:
		_change_state(new_state)
		
		
func _input(event):
	var new_state = current_state.handle_input(event)
	if new_state:
		_change_state(new_state)


func _change_state(state_name):
	current_state.exit()

	# You can control the flow of states and transfer data between states here
	# It's better than doing it in the individual state objects so they don't get coupled with one another
	if current_state == states_map['die']:
#		set_active(false) # implement
		return
	if state_name == 'jump':
		$Jump.initialize(current_state.speed, current_state.velocity)
		
	current_state = states_map[state_name]
	current_state.enter()
	emit_signal('state_changed', current_state.get_name())


func _on_animation_finished(anim_name):
#	if not active:
#		return # Set up active processing stuff. see StateMachine in Godot final example!
	current_state._on_animation_finished(anim_name)
	

func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state('die')
	else:
		_change_state('stagger')
