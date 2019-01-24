extends Area2D

signal attack_finished

enum STATES { IDLE, ATTACK }
var state = null

const MAX_COMBO_COUNT = 3
var combo_count = 0

var combo = [
	{
		'damage': 1,
		'animation': 'attack_fast'
	},
	{
		'damage': 1,
		'animation': 'attack_fast'
	},
	{
		'damage': 3,
		'animation': 'attack_medium'
	},
]
var attack_current = {}

var hit_objects = []

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	$AnimationPlayer.connect('animation_finished', self, "_on_AnimationPlayer_animation_finished")
	_change_state(IDLE)
	

func _change_state(new_state):
	match state:
		ATTACK:
			hit_objects = []
	match new_state:
		IDLE:
			combo_count = 0
			$AnimationPlayer.play('idle')
			monitoring = false
		ATTACK:
			attack_current = combo[combo_count - 1]
			$AnimationPlayer.play(attack_current['animation'])
			monitoring = true
	state = new_state


func attack():
	combo_count += 1
	_change_state(ATTACK)
	

func _on_body_entered(body):
	print('attacked')
	if body.get_rid().get_id() in hit_objects or body.is_a_parent_of(self):
		return
	hit_objects.append(body.get_rid().get_id())
	body.take_damage(self, attack_current['damage'])


func _on_AnimationPlayer_animation_finished(name):
	if name == "idle":
		return
		
	if combo_count < MAX_COMBO_COUNT:
		attack()
	else:
		_change_state(IDLE)
		emit_signal("attack_finished")