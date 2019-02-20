extends KinematicBody2D

signal state_changed # do i need?

var look_direction = Vector2()
var last_move_direction = look_direction
var sprite_direction = "down"
var input_direction = Vector2()


var current_state = null

onready var states_map = {
	'idle': $StateMachine/Idle,
	'jump': $StateMachine/Jump,
	'bump': $StateMachine/Bump,
	'move': $StateMachine/Move,
}

func _ready():
	current_state = $StateMachine/Idle
	_change_state('idle')
	
	
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
	if state_name == 'jump':
		$StateMachine/Jump.initialize(current_state.speed, current_state.velocity)
		
	current_state = states_map[state_name]
	current_state.enter(self)
	emit_signal('state_changed', current_state.get_name())


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