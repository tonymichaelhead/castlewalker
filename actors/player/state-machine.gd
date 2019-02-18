extends KinematicBody2D

signal state_changed # do i need?

var look_direction = Vector2()
var sprite_direction = "down"

var current_state = null

onready var states_map = {
	'idle': $StateMachine/Idle,
	'jump': $StateMachine/Jump,
}

func _ready():
	current_state = $StateMachine/Idle
	_change_state('idle')
	
	
func _physics_process(delta):
	var new_state = current_state.update(self, delta)
	if new_state:
		_change_state(new_state)
		
		
func _input(event):
	var new_state = current_state.handle_input(self, event)
	if new_state:
		_change_state(new_state)


func _change_state(state_name):
	current_state.exit(self)

	# You can control the flow of states and transfer data between states here
	# It's better than doing it in the individual state objects so they don't get coupled with one another
	if state_name == 'jump':
#		$States/Jump.initialize(current_state.speed, current_state.velocity)
		pass
		
	current_state = states_map[state_name]
	current_state.enter(self)
	emit_signal('state_changed', current_state.get_name())
	

func animation_switch(animation):
	print('playing anim')
	var new_animation = str(animation, "_", sprite_direction)
	if $AnimationPlayer.current_animation != new_animation:
		$AnimationPlayer.play(new_animation)