\extends Control

export(PackedScene) var AddItemWidget

func initialize(inventory):
	for item in ItemDatabase.get_items():
		var widget = AddItemWidget.instance()
		widget.track(inventory, item)
		$MarginContainer/VBoxContainer.add_child(widget)
