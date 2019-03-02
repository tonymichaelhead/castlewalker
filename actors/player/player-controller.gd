extends "res://actors/actor.gd"

var knockback_direction = Vector2()

onready var state_machine = $StateMachine
#onready var camera = $Camera

func _ready():
	state_machine.current_state = state_machine.states_map['idle']
	state_machine.start()


#func reset(target_global_position):
#	.reset(target_global_position)
##	anim_player.play('SETUP') # implement?
#	camera.offset = Vector2()
#	camera.current = true


func move(velocity):
	move_and_slide(velocity, Vector2(), 5, 2)
	emit_signal('position_changed',position)
	var slide_count = get_slide_count()
	return get_slide_collision(slide_count -1) if slide_count else null


func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	knockback_direction = (global_position - source.global_position).normalized()
	$Health.take_damage(amount)


func _on_HitBox_body_entered(body):
	if body.is_in_group('monster'):
		take_damage(body, 2)