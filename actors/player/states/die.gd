extends "res://utils/state/state.gd"


func enter(host):
	owner.set_dead(true)
	owner.get_node('AnimationPlayer').play('die')


func _on_animation_finished(anim_name):
	emit_signal("finished", "none")