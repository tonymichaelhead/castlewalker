extends "res://utils/state/state.gd"

func enter():
	if not owner.weapon:
		print('not weapon')
		return 'idle'

	owner.weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")
	owner.weapon.attack()
	owner.get_node('AnimationPlayer').play("idle")
	owner.set_physics_process(false)
	
	
func exit():
	owner.set_physics_process(true)
	
	
func _on_Weapon_attack_finished():
	emit_signal("finished", "idle")