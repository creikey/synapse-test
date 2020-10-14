extends Line2D

class_name ConnectionLine

var target := Vector2(100, 100) setget set_target # in global coordinates

func set_target(new_target):
	points[1] = to_local(new_target)
