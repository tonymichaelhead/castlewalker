extends Control

signal open()
signal closed()

func _ready():
	set_process_input(false)

func initialize(args=[]):
	set_process_input(true)

func open():
	emit_signal("open")
	set_process_input(true)
	show()

func close():
	set_process_input(false)
	emit_signal("closed")
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()