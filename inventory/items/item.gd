extends Node

signal amount_changed(amount)
signal depleted()

export(Texture) var icon = preload("res://interface/theme/icons/purse.png")
export(String) var display_name = "Item"
export(String, MULTILINE) var description = "The base item class"

export(int) var price = 0

export(bool) var usable = true
export(bool) var unique = false

export(int) var amount = 1 setget set_amount

func use(user):
	if unique or not usable:
		return
	if amount == 0:
		return
	self.amount -= 1
	_apply_effect(user)

func set_amount(value):
	amount = value
	assert amount >= 0
	emit_signal("amount_changed", amount)
	if amount == 0:
		queue_free()
		emit_signal("depleted")

# Virtual method
func _apply_effect(user):
	print("Item %s has no apply_effect override" % name)
