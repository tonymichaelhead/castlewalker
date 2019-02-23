extends "res://utils/state/state.gd"

var fire_scene = preload("res://particles/fiery_cloud/Fireball.tscn")
var fire_count = 0
var fire_direction = Vector2()


func enter():
	owner.get_node('AnimationPlayer').play('cast_fire')
	cast_fire()


func exit():
	fire_count = 0
	owner.get_node('FireballTimer').stop()


func cast_fire():
	owner.get_node('FireballTimer').start()
	fire_direction = owner.look_direction
	

func process_fire():
	fire_count += 1
	var new_fire = fire_scene.instance()
#	new_fire.position = global_position + fire_count * last_move_direction * 80.0
	new_fire.position = Vector2() + fire_count * fire_direction * 80.0
	owner.add_child(new_fire)


func _on_animation_finished(anim_name):
	if anim_name == 'cast_fire':
		emit_signal('finished', 'idle')


func _on_FireballTimer_timeout():
	process_fire()
