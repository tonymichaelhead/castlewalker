extends "res://interface/menu.gd"

export(PackedScene) var BuyMenu = preload("res://interface/shop/menus/BuySubMenu.tscn")
export(PackedScene) var SellMenu = preload("res://interface/shop/menus/SellSubMenu.tscn")

onready var _buttons = $Column/Buttons
onready var _submenu = $Column/Menu

func open(shop, buyer):
	$Column/Buttons/BuyButton.connect("pressed", self, "open_submenu", 
		[BuyMenu, shop, buyer, shop.inventory])
	$Column/Buttons/SellButton.connect("pressed", self, "open_submenu",
		[SellMenu, shop, buyer, buyer.get_node("Inventory")])
	show()
	_buttons.get_child(0).grab_focus()

func close():
	queue_free()
	.close()

func _on_QuitButton_pressed():
	close()

func open_submenu(Menu, shop, buyer, inventory):
	var pressed_button = get_focus_owner()
	var menu = Menu.instance()
	_submenu.add_child(menu)
	menu.initialize(shop, buyer, inventory.get_items())
	
	set_process_input(false)
	yield(menu, "closed")
	set_process_input(true)
	pressed_button.grab_focus()
