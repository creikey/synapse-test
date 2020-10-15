extends Node2D

onready var _graph = $"../Graph"

func _draw():
	var current_ring: int = _graph._max_ring_of_complexity
	while current_ring > 0:
		var progress_fraction: float = float(current_ring) / float(_graph._max_ring_of_complexity)
		var ring_color_brightest = _graph.ring_color_brightest
		var current_color: Color = Color.from_hsv(ring_color_brightest.h, ring_color_brightest.s, lerp(ring_color_brightest.v, 0.1, progress_fraction))
		draw_circle(Vector2(), float(current_ring)*_graph._RING_RADIUS, current_color)
		current_ring -= 1
