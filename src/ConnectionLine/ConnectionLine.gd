extends Line2D

class_name ConnectionLine

var target := Vector2(100, 100) setget set_target # in global coordinates

var _target_by_reference: Array = [ target ] # so direction arrows can access target by reference

func set_target(new_target):
	points[1] = to_local(new_target)
	target = new_target
	_target_by_reference[0] = target
#	for c in get_children():
#		c.queue_free()
#	var cur_distance_along: float = 0.0
#	while cur_distance_along < global_position.distance_to(target):
#		var cur_direction_arrow: DirectionArrow = preload("res://DirectionArrow.tscn").instance()
#		add_child(cur_direction_arrow)
#		cur_direction_arrow.follow_line(global_position, target, cur_distance_along)
#		cur_direction_arrow.connect("end_of_life")
#		cur_distance_along += 200.0


func _on_ArrowSpawnTimer_timeout():
	var new_arrow: DirectionArrow = preload("res://ConnectionLine/DirectionArrow.tscn").instance()
	add_child(new_arrow)
	new_arrow.modulate = default_color
	new_arrow.follow_line(global_position, _target_by_reference, 0.0)
