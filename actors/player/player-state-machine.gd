extends "res://utils/state/state-machine.gd"


func _ready():
	states_map = {
		'idle': $Idle,
		'jump': $Jump,
		'bump': $Bump,
		'move': $Move,
		'attack': $Attack,
		'casting_fire': $CastingFire,
		'stagger': $Stagger,
		'die': $Die,
	}
	for state in get_children():
		state.connect('finished', self, '_change_state')
	

func _on_Health_health_changed(new_health):
	if new_health == 0:
		_change_state('die')
	else:
		_change_state('stagger')
