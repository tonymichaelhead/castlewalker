extends Node

export(String, FILE, "*.tscn") var LEVEL_START = "res://levels/DemoLevel.tscn"
export(PackedScene) var Player = preload("res://actors/player/Player.tscn")

var map
var player


func initialize():
	player = Player.instance()
	change_level(LEVEL_START)
	add_child(player)
	

func change_level(scene_path):
	if map:
		map.queue_free()
	map = load(scene_path).instance()
	add_child(map)
	move_child(map, 0)
	var spawn = map.get_node("PlayerSpawningPoint")
	player.global_position = spawn.global_position
	
	
func get_doors():
	var doors = []
	for door in get_tree().get_nodes_in_group("doors"):
		if not map.is_a_parent_of(door):
			continue
		doors.append(door)
	return doors