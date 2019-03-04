extends Node

func get_item(reference):
	for item in get_items():
		if reference.name == item.name:
			return item.duplicate()

func get_items():
	return get_children()
