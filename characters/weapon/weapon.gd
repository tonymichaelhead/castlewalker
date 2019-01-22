extends Area2D

signal attack_finished

enum STATES { IDLE, ATTACK }
var state = null

var hit_bodies = []

func _ready():
	$AnimationPlayer.connect('animation_finished', self, "_on_AnimationPlayer_animation_finished")
	_change_state(IDLE)
	

func _change_state(new_state):
	match state:
		ATTACK:
			hit_bodies = []
	match new_state:
		IDLE:
			set_physics_process(false)
			$AnimationPlayer.play('idle')
		ATTACK:
			set_physics_process(true)
			$AnimationPlayer.play('attack_straight')
	state = new_state


func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		var body_id = body.get_rid().get_id()
		if body_id in hit_bodies:
			continue
		if body.has_node("Health") and not body.is_a_parent_of(self):
			hit_bodies.append(body_id)
			body.get_node("Health").take_damage(1)

func attack():
	_change_state(ATTACK)

func _on_AnimationPlayer_animation_finished(name):
	if name == "idle":
		return
	_change_state(IDLE)
	emit_signal("attack_finished")