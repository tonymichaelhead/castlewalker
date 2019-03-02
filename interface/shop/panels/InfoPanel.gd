extends Control

func initialize(purse):
	purse.connect("coins_changed", self, "_on_Purse_coins_changed")
	update_coins(purse.coins)

func update_coins(amount):
	$MoneyPanel/Count.text = str(amount)

func update_amount(amount):
	$OwnedPanel/Count.text = str(amount)


func _on_Purse_coins_changed(value):
	update_coins(value)
	
	
func _on_ItemButton_pressed(item):
	update_amount(item.amount)


func _on_ItemsList_focused_button_changed(button):
	update_amount(button.amount)
