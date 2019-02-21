extends "res://utils/state/state.gd"

func enter(host):
	if not host.weapon:
		print('not weapon')
		return 'idle'

	host.weapon.connect("attack_finished", self, "_on_Weapon_attack_finished")
	host.weapon.attack()
	host.get_node('AnimationPlayer').play("idle")
	host.set_physics_process(false)
	
	
func exit(host):
	owner.set_physics_process(true)
	
	
func _on_Weapon_attack_finished():
	emit_signal("finished", "idle")