extends "res://utils/state/state.gd"

export(float) var knockback_force = 10.0
const KNOCKBACK_DURATION = 0.4


func enter():
	owner.get_node('AnimationPlayer').play('stagger')
	owner.get_node('Tween').interpolate_property(
		owner, 
		'position', 
		owner.position, 
		owner.position + 
		knockback_force * 
		owner.knockback_direction, 
		KNOCKBACK_DURATION, 
		Tween.TRANS_QUART, 
		Tween.EASE_OUT
	)
	owner.get_node('Tween').start()


func _on_Tween_tween_completed(object, key):
	if key == ":position":
		emit_signal("finished", "idle")