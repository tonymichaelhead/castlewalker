extends Node

func _ready():
	$Interface/AddItemsMenu.initialize($Inventory)
	$Interface/ItemsMenu.initialize($Inventory)
