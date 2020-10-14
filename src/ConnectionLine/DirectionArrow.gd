extends Sprite

class_name DirectionArrow

const SPEED = 100.0 # pixels per second

signal end_of_life # reached target point, dying

var _target_modulate: float = 0.0
var _end_point: Array = [ Vector2() ]
var _distance_along: float = 0.0

var _dying: bool = false

# end is an array so can be passed by reference
func follow_line(start: Vector2, end: Array, starting_distance_along: float):
	_end_point = end
	rotation = (_end_point[0] - start).angle()
	_distance_along = starting_distance_along
	_target_modulate = 1.0
	set_process(true)

func _ready():
	modulate.a = 0.0
	set_process(false)

func _process(delta):
	modulate.a = lerp(modulate.a, _target_modulate, delta*4.0)
	_distance_along += SPEED*delta
	# DIRTY HACK! DON'T GET PARENT EVERY FRAME >:(
	var start_pos: Vector2 = get_parent().global_position
	var direction_vector: Vector2 = (_end_point[0] - start_pos).normalized()
	global_position = start_pos + _distance_along * direction_vector
	rotation = direction_vector.angle()
	if modulate.a < 0.01 and _dying:
		queue_free()
	if direction_vector.dot((_end_point[0] - global_position).normalized()) < -0.5:
		_die()
	

func _die():
	if _dying:
		return
	_target_modulate = 0.0
	_dying = true
	emit_signal("end_of_life")
