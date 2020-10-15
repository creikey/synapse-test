extends Node2D

class_name Synapse

export var ring_color_brightest: = Color(1, 1, 1)

const _RING_RADIUS: float = 500.0
const _INSTRUCTION_PACK: PackedScene = preload("res://Instruction/Instruction.tscn")
const _EXPECTED_COLUMNS: int = 6

# index to node reference
var _currently_displayed: Dictionary = {}

# data cached from load
var _max_ring_of_complexity: int = -1

func get_data() -> String:
	# has the header line as the top
	var lines_to_return: Array = ["index	Instructional Step	Complexity Layer ( starts at 1 )	The next step's indices	Analyzed ( true/false ), if blank will be false	Position Override ( if blank auto sorts )"]
	
	for index in _currently_displayed.keys():
		var cur_line: String = ""
		var cur_instruction: Instruction = _currently_displayed[index]
		cur_line += str(index, "	")
		cur_line += str(_escape_string(cur_instruction.step_text), "	")
		cur_line += str(cur_instruction.complexity_layer, "	")
		if cur_instruction.next_step_indices[0] == -1:
			cur_line += "	"
		else:
			cur_line += str(_array_to_string(cur_instruction.next_step_indices), "	")
		if cur_instruction.analyzed_bool == null:
			cur_line += "	"
		else:
			cur_line += str(var2str(cur_instruction.analyzed_bool), "	")
		if cur_instruction.position_override_vector2 == null:
			pass
		else:
			cur_line += var2str(cur_instruction.position_override_vector2)
		lines_to_return.append(cur_line)
		
	
	return PoolStringArray(lines_to_return).join("\n")
	

func _on_UI_load_data(data_string: String):
	# delete previous synapse stuff
	for node in _currently_displayed.values():
		node.queue_free()
	_currently_displayed.clear()
	
	# load
	var valid: bool = false
	_max_ring_of_complexity = -1
	var line_number: int = 0
	for line in data_string.split("\n"):
		var data: Array = line.split("	")
		if data.size() != _EXPECTED_COLUMNS:
			OS.alert(str("Line number ", line_number, " in the data has ", data.size(), " columns of data when I expect ", _EXPECTED_COLUMNS, " columns!"))
			continue
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
#		var next_step_indices: Array = int(data[3])
		var next_step_indices: Array = _intstring_to_array(data[3])
		if next_step_indices.size() == 0:
			next_step_indices.append(-1)
		var position_override_vector2 = null
		
		# TODO analyzed flag
		
		if data[5] != "":
			position_override_vector2 = str2var(data[5])

		_new_instruction(int(data[0]), _unescape_string(data[1]), int(data[2]), next_step_indices, position_override_vector2)
		line_number += 1

	# initialize visuals after all have been loaded, to get rect size for sorting
	for cur_instruction in _currently_displayed.values():
		cur_instruction.initialize_visually()

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
			cur_instruction = _currently_displayed.get(cur_instruction.next_step_indices[0])
	
	# iterating again... bad!
	for cur_instruction in _currently_displayed.values():
		if cur_instruction.position_override_vector2 != null:
			cur_instruction.rect_position = cur_instruction.position_override_vector2
	
	# initialize visuals again after all have been loaded, this time for the lines
	for cur_instruction in _currently_displayed.values():
		cur_instruction.initialize_visually()
	
	$"../Circles".update()
#	update() # will draw rings of complexity

static func _escape_string(s: String) -> String: # replaces newlines with `\n`
	return s.c_escape()

static func _unescape_string(s: String) -> String:
	return s.c_unescape()

static func _array_to_string(a: Array) -> String:
	var to_return: String = ""
	for i in a.size():
		var extension: String = ", "
		if i == a.size() - 1: # last element, no comma
			extension = "" 
		to_return += str(a[i], extension)
	return to_return

static func _intstring_to_array(s: String) -> Array:
	if s == "":
		return []
	var to_return: Array = []
	var initial_split: PoolStringArray = s.split(",")
	
	for s in initial_split:
		to_return.append(int(s))
	
	return to_return

func _new_instruction(index: int, text: String = "placeholder", complexity: int = 1, next_indices: Array = [ -1 ], position_override_vector2 = null):
	var cur_instruction: Instruction = _INSTRUCTION_PACK.instance()
	add_child(cur_instruction)
	
	_currently_displayed[index] = cur_instruction
	
	_max_ring_of_complexity = int(max(_max_ring_of_complexity, complexity))
	
	cur_instruction.index = index
	cur_instruction.step_text = text
	cur_instruction.complexity_layer = complexity
	cur_instruction.next_step_indices = next_indices.duplicate(true)
	cur_instruction.position_override_vector2 = position_override_vector2
	cur_instruction.currently_displayed = _currently_displayed
