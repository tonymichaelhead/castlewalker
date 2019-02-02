extends Node

func _ready():
	$UI.initialize($Inventory)
	for item in ItemDatabase.get_items():
		$Inventory.add(item, 3)
