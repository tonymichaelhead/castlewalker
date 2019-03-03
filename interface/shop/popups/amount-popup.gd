extends "res://interface/menu.gd"

signal amount_confirmed(value)

onready var _amount_label = $VBoxContainer/Slider/Amount
onready var _slider = $VBoxContainer/Slider/HSlider
#onready var _accept_button = $VBoxContainer/OkButton TODO: probz delete


func open():
	popup_centered()
	.open()
	var amount = yield(self, "amount_confirmed")
	close()
	return amount
	
	
func initialize(value, max_value):
	_amount_label.initialize(value, max_value)
	_slider.initialize(value, max_value)
	_slider.grab_focus()
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("amount_confirmed", 0)
		get_tree().set_input_as_handled()
	# TODO: Do the same as ui accept, but checking if the ok button was clicked
	if event.is_action_pressed("ui_accept"):
		confirm_amount()
	

func confirm_amount():
	print('amount confirmed')
	emit_signal("amount_confirmed", _slider.value)
	get_tree().set_input_as_handled()

func _on_OkButton_pressed():
	confirm_amount()


