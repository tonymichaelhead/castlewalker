extends Node2D

var hornet_scene = preload("Hornet.tscn")
export(int) var MAX_HORNET_COUNT = 2

func _ready():
	randomize()
	$Timer.wait_time = randf() * 1.5 + 1.0


func _on_Timer_timeout():
	if $Hornets.get_child_count() < MAX_HORNET_COUNT:
		spawn_hornet()
		
		
func spawn_hornet():
	var new_hornet = hornet_scene.instance()
	new_hornet.global_position = calculate_random_spawn_position()
	$Hornets.add_child(new_hornet)
	
	
func calculate_random_spawn_position():
	var random_position = Vector2()
	var center_position = $SpawnCircle.global_position
	var shape_radius = $SpawnCircle.shape.radius
	
	randomize()
	var random_radius = randf() * shape_radius / 2 + shape_radius / 2
	randomize()
	var random_angle = randf() * 2.0 * PI
	
	random_position = center_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
	return random_position