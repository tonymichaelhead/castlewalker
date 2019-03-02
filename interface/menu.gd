extends Control

signal open()
signal closed()

func initialize(args=[]):
	return

func open():
	emit_signal("open")
	show()

func close():
	emit_signal("closed")
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()
