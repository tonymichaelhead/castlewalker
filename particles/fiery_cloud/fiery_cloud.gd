extends Area2D

var hit_objects = []

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	$AnimationPlayer.play('fire')


func _physics_process(delta):
	position = position


func _on_body_entered(body):
	if body.get_rid().get_id() in hit_objects or body.is_a_parent_of(self):
		return
	hit_objects.append(body.get_rid().get_id())
	body.take_damage(self, 3)