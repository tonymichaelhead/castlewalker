extends Control

func initialize(inventory):
	inventory.connect("content_changed", self, "_on_Inventory_content_changed")

func _on_Inventory_content_changed(items_as_string):
	$Label.text = items_as_string
