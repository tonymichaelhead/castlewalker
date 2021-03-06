extends Node

signal health_changed
signal health_depleted

var health = 0
export(int) var max_health = 5

var status = null
enum STATUSES { NONE, INVINCIBLE }


func _ready():
	health = max_health
	_change_status(NONE)

	
func _change_status(new_status):
	status = new_status


func heal(amount):
	health += amount
	health = min(health, max_health)
	emit_signal("health_changed", health)


func take_damage(amount):
	if status == INVINCIBLE:
		return
	health -= amount
	if health < 0:
		health = 0
	if health == 0:
		emit_signal("health_depleted")
	emit_signal("health_changed", health)
	print("%s took %s damage. Health: %s/%s" % [get_path(), amount, health, max_health])
	