extends Node

onready var level_loader = $LevelLoader
onready var transition = $Overlays/TransitionColor

func _ready():
	level_loader.initialize()
	for door in level_loader.get_doors():
		door.connect("player_entered", self, "_on_Door_player_entered")


func change_level(scene_path):
	get_tree().paused = true
#	transition.fade_to_color()
#	yield(transition, "transition_finished")

	level_loader.change_level(scene_path)
	for door in level_loader.get_doors():
		door.connect("player_entered", self, "on_Door_player_entered")
	
#	transition.fade_from_color()
#	yield(transition, "transition_finished")
	get_tree().paused = false
	
	
func _on_Door_player_entered(target_map_path):
	change_level(target_map_path)