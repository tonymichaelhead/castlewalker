extends Control

var health_current = 0

func initialize():
	var health_node
	for node in get_tree().get_nodes_in_group("actor"):
		if node.name == "Player":
			health_node = node.get_node("Health")
			break
	health_node.connect("health_changed", self, "_on_Health_health_changed")
	$TextureProgress.max_value = health_node.max_health
	animate_bar(health_node.health)
	health_current = health_node.health
	
	
func _on_Health_health_changed(new_health):
	animate_bar(new_health)
	health_current = new_health
	

func animate_bar(target_value):
	$TextureProgress.animate_value(target_value)
	$TextureProgress.update_color(target_value)