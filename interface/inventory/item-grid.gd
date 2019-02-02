extends GridContainer

func initialize():
	update_focus_neighbours()
	for button in get_children():
		button.connect("tree_exited", self, "on_ItemButton_tree_exited", [button])
	get_child(0).grab_focus()
	
func on_ItemButton_tree_exited(button):
	var focus_neighbour = null
	if button.get_index():
		focus_neighbour = button.focus_neighbour_left
	else:
		focus_neighbour = button.focus_neighbour_right
	button.get_node(focus_neighbour).grab_focus()
	update_focus_neighbours(button)
	
func update_focus_neighbours(ignore=null):
	var buttons_to_update = get_children()
	if ignore:
		buttons_to_update.remove(ignore.get_index())
	var index = 0
	var count = buttons_to_update.size()
	for button in buttons_to_update:
		var index_previous = index - 1
		var index_next = (index + 1) % count
		button.focus_neighbour_left = button.get_path_to(buttons_to_update[index_previous])
		button.focus_neighbour_right = button.get_path_to(buttons_to_update[index_next])
		index += 1
