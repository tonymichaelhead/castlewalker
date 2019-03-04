extends Node

signal coins_changed(coins)

export(int) var coins = 0
export(int) var MAXIMUM = 100


func has_coins(amount):
	return coins >= amount


func add_coins(amount):
	coins = min(coins + amount, MAXIMUM)
	emit_signal("coins_changed", coins)


func remove_coins(amount):
	coins = max(0, coins - amount)
	emit_signal("coins_changed", coins)
