extends "res://interface/menu.gd"

export(String, "sell_to", "buy_from") var ACTION
onready var _items_list = $Row/ItemsList
onready var _description_panel = $DescriptionPanel
onready var _info_panel = $Row/InfoPanel


func initialize(shop, buyer, items):
	for item in items:
		var price = shop.get_buy_value(item) if ACTION == "buy_from" else item.price
		var item_button = _items_list.add_item_button(item, price)
		item_button.connect("pressed", self, "_on_ItemButton_pressed", [shop, buyer, item])
		item_button.connect("pressed", _info_panel, "_on_ItemButton_pressed", [item])
	_items_list.initialize()
	_items_list.connect("focused_button_changed", self, "_on_ItemList_focused_button_changed")
	_info_panel.initialize(buyer.get_node("Purse"))
	open()


func close():
	queue_free()
	.close()


func _on_ItemButton_pressed(shop, buyer, item):
	assert ACTION != null
	shop.call(ACTION, buyer, item)
	

func _on_ItemList_focused_button_changed(button):
	_description_panel.display(button.description)