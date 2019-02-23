"""
Base interface for all states: it doesn't do anything in itself
but forces us to pass the right arguments to the methods below
and makes sure every State object had all of these methods.
"""
extends Node

signal finished(next_state_name)

func enter(host):
	return

func exit(host):
	return

func handle_input(event):
	return

func update(host, delta):
	return

func _on_animation_finished(anim_name):
	return