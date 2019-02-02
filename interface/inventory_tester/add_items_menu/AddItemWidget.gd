extends VBoxContainer

func track(inventory, item):
	$Name.text = item.name
	$HBoxContainer/AddButton.connect("pressed", inventory, "add", [item])
	$HBoxContainer/RemoveButton.connect("pressed", inventory, "trash", [item])
