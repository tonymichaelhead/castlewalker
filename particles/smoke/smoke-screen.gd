extends Particles2D

func play():
	emitting = true
	for child in get_children():
		if child.get_class() == "Particles2D":
			continue
		child.emitting = true