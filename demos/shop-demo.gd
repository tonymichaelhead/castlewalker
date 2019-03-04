extends Node

onready var ShopMenu = preload("res://interface/shop/ShopMenu.tscn")

func _on_Seller_shop_open_requested(shop, user):
	if not user.has_node("Inventory"):
		return

	var shop_menu = ShopMenu.instance()
	$UI.add_child(shop_menu)
	shop_menu.open(shop, user)
	
	get_tree().paused = true
	yield(shop_menu, "closed")
	get_tree().paused = false
