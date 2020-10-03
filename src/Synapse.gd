extends Node2D

class_name Synapse

export var ring_color_brightest: = Color(1, 1, 1)

const _RING_RADIUS: float = 500.0
const _INSTRUCTION_PACK: PackedScene = preload("res://Instruction.tscn")

# index to node reference
var _currently_displayed: Dictionary = {}

# data cached from load
var _max_ring_of_complexity: int = -1

func get_data() -> String:
	return ""

func _draw():
	var current_ring: int = _max_ring_of_complexity
	while current_ring > 0:
		var progress_fraction: float = float(current_ring) / float(_max_ring_of_complexity)
		var current_color: Color = Color.from_hsv(ring_color_brightest.h, ring_color_brightest.s, lerp(ring_color_brightest.v, 0.1, progress_fraction))
		draw_circle(Vector2(), float(current_ring)*_RING_RADIUS, current_color)
		current_ring -= 1
	

func _on_UI_load_data(data_string: String):
	# delete previous synapse stuff
	for node in _currently_displayed.values():
		node.queue_free()
	_currently_displayed.clear()
	
	# load
	var valid: bool = false
	_max_ring_of_complexity = -1
	for line in data_string.split("\n"):
		var data: Array = line.split("	")
		if data[0] == "index":
			valid = true
			continue
		if not valid:
			OS.alert("Invalid data!")
			return
		if data[1] == "": # empty line
			continue
#		printt("Making instruction with text: ", data[1])
		#index, instruction step, complexity, next index
		_new_instruction(int(data[0]), data[1], int(data[2]), int(data[3]))

	# sort by ring of complexity
	var instructions_in_layer1: Array = []
	for instruction in _currently_displayed.values():
		if instruction.complexity_layer == 1:
			instructions_in_layer1.append(instruction)
	for i in instructions_in_layer1.size():
		# TODO offset final position if another thing in its spot already ( layer of complexity )
		var angle: float = (float(i) / float(instructions_in_layer1.size()))*2.0*PI
		var cur_instruction: Instruction = instructions_in_layer1[i]
		while cur_instruction != null:
			cur_instruction.rect_position = Vector2(cos(angle), sin(angle)) * ((float(cur_instruction.complexity_layer - 1)*_RING_RADIUS) + _RING_RADIUS/2.0) - cur_instruction.rect_size/2.0
			cur_instruction = _currently_displayed.get(cur_instruction.next_step_index)
	

	update() # will draw rings of complexity

func _new_instruction(index: int, text: String = "placeholder", complexity: int = 1, next_index: int = -1):
	var cur_instruction: Instruction = _INSTRUCTION_PACK.instance()
	add_child(cur_instruction)
	
	_currently_displayed[index] = cur_instruction
	
	_max_ring_of_complexity = max(_max_ring_of_complexity, complexity)
	
	cur_instruction.index = index
	cur_instruction.step_text = text
	cur_instruction.complexity_layer = complexity
	cur_instruction.next_step_index = next_index
	
	cur_instruction.initialize_visually()
