extends Node

signal took_damage(amount)
signal took_hit(amount)
signal health_changed(new_health)
signal health_depleted

var health = 0
export(int) var max_health = 9

func _ready():
	health = max_health

func heal(amount):
	health += amount
	health = min(health, max_health)
	emit_signal("health_changed", health)

func take_damage_from(source):
	emit_signal("took_hit")
	take_damage(source.damage)
	if not source.effect:
		return
	apply_status(source.effect)

func take_damage(amount):
	health -= amount
	health = max(0, health)
	emit_signal("health_changed", health)
	if health == 0:
		emit_signal("health_depleted")
		return
	else:
		emit_signal("took_damage", amount)
