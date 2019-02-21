extends '../motion.gd'

const BUMP_DURATION = 0.2
const BUMP_DISTANCE = 30
const MAX_BUMP_HEIGHT = 20

var height = 0.0 setget set_height

var timer = 0.0

func enter(host):
	owner.get_node('AnimationPlayer').stop()
	
	var tween_node = host.get_node('Tween')
	tween_node.interpolate_property(host, 'position', host.position, host.position + BUMP_DISTANCE * -host.last_move_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_node.start()
	timer = 0.0


func update(host, delta):
	timer += delta
	if timer >= BUMP_DURATION:
		return 'idle'


func _animate_bump_height(progress):
	self.height = pow(sin(progress * PI), 0.5) * MAX_BUMP_HEIGHT


func set_height(value):	
	height = value
	owner.get_node('Pivot').position.y = - value
	var shadow_scale = 0.48710 - value / MAX_BUMP_HEIGHT * 0.4
	owner.get_node('Shadow').scale = Vector2(shadow_scale, shadow_scale)