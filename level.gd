extends Node

func _input(event):
	if event.is_action_pressed("simulate_player_damage"):
		$YSort/Player/Health.take_damage(2)
	if event.is_action_pressed("simulate_player_heal"):
		$YSort/Player/Health.heal(1)

