extends '../steering-monster.gd'

enum STATES { IDLE, FOLLOW, RETURN, DIE }

export(float) var FOLLOW_RANGE = 200.0
export(float) var MAX_FLY_SPEED = 400.0

func _ready():
	_change_state(IDLE)
	

func _change_state(new_state):
	match new_state:
		IDLE:
			pass
		DIE: queue_free()
	state = new_state
	
	
func _physics_process(delta):
	var current_state = state
	match current_state:
		IDLE:
			if position.distance_to(target_position) < FOLLOW_RANGE:
				_change_state(FOLLOW)
		FOLLOW:
			if position.distance_to(target_position) > FOLLOW_RANGE:
				_change_state(RETURN)
			
			velocity = follow(velocity, target_position, MAX_FLY_SPEED)
			move_and_slide(velocity)
			
			if get_slide_count() == 0:
				return
			var body = get_slide_collision(0).collider
			if body.is_in_group('character'):
				body.take_damage(self, 4)
				
		RETURN:
			velocity = arrive_to(velocity, spawn_position)
			move_and_slide(velocity)
	
			if position.distance_to(spawn_position) < ARRIVE_DISTANCE:
				_change_state(IDLE)
			
