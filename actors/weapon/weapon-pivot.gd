extends Position2D

func _ready():
	$'..'.connect("direction_changed", self, "_on_Parent_direction_changed")

func _on_Parent_direction_changed(direction):
	rotation =  direction.angle()
