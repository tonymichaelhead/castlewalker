extends Area2D

signal player_entered(map_path)

export(String, FILE, "*.tscn") var map_path
var PlayerController = preload("res://actors/player/player-controller.gd")


func _ready():
	assert map_path != ""
	
	
func _on_body_entered(body):
	if not body is PlayerController:
		return
	print('about to emit playerentered')
	emit_signal("player_entered", map_path)
