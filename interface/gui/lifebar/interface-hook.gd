extends RemoteTransform2D
# THIS SCRIPT WAS CREATED FOR DEBUGGING PURPOSES ONLY

func _ready():
	print(owner.name)
	print(global_position)
	
	
func _physics_process(delta):
	print(owner.name)
	print(global_position)