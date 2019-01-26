extends Node

export(PackedScene) var Lifebar

func _ready():
	for actor in get_tree().get_nodes_in_group("actor"):
		create_lifebar(actor)
	for spawner in get_tree().get_nodes_in_group("monster_spawner"):
		spawner.connect("spawned_monster", self, "on_MonsterSpawner_spawned_monster")
	
		
func on_MonsterSpawner_spawned_monster(monster_node):
	create_lifebar(monster_node)	
		


func create_lifebar(actor):	
	var lifebar = Lifebar.instance()
	add_child(lifebar)
	lifebar.initialize(actor)
