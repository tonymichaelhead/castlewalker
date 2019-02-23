extends KinematicBody2D

export(String) var weapon_path = ""
var weapon = null

signal direction_changed(new_direction)
signal position_changed(new_position)
signal died()

onready var health = $Health

var look_direction = Vector2(1, 0) setget set_look_direction
var last_move_direction = look_direction
var sprite_direction = "down"
var input_direction = Vector2()


func _ready():
	if not weapon_path:
		return
	var weapon_node = load(weapon_path).instance()

	$WeaponPivot/WeaponSpawn.add_child(weapon_node)
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)


func set_dead(value):
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = true
	emit_signal('died')
	

func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)
	
	
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