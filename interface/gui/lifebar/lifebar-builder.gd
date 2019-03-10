extends Node

const Lifebar = preload("res://interface/gui/lifebar/HookableLifebar.tscn")


func initialize(monsters, monster_spawners):
	for monster in monsters:
		create_lifebar(monster)
	for spawner in monster_spawners:
		spawner.connect("spawned_monster", self, "on_MonsterSpawner_spawned_monster") # or monster_spawners.connect?
	

func on_MonsterSpawner_spawned_monster(monster_node):
	create_lifebar(monster_node)	


func create_lifebar(actor):	
	var lifebar = Lifebar.instance()
	add_child(lifebar)
	lifebar.initialize(actor)
