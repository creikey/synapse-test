extends Node2D

class_name Synapse

export var ring_color_brightest: = Color(1, 1, 1)

const _RING_RADIUS: float = 500.0
const _INSTRUCTION_PACK: PackedScene = preload("res://Instruction/Instruction.tscn")
const _EXPECTED_COLUMNS: int = 7

# index to node reference
var _currently_displayed: Dictionary = {}

# data cached from load
var _max_ring_of_complexity: int = -1

var _selected_instructions: Array = []

func get_data() -> String:
	# has the header line as the top
	var lines_to_return: Array = ["index	Instructional Step	Complexity Layer ( starts at 1 )	The next step's indices	Analyzed ( true/false ), if blank will be false	Position Override ( if blank auto sorts )	Image ( URL or data from application )"]
	
	for index in _currently_displayed.keys():
		var cur_line: String = ""
		var cur_instruction: Instruction = _currently_displayed[index]
		cur_line += str(index, "	")
		cur_line += str(_escape_string(cur_instruction.step_text), "	")
		cur_line += str(cur_instruction.complexity_layer, "	")
		cur_line += str(_array_to_string(cur_instruction.next_step_indices), "	")
		if cur_instruction.analyzed_bool == null:
			cur_line += "	"
		else:
			cur_line += str(var2str(cur_instruction.analyzed_bool), "	")
		if cur_instruction.position_override_vector2 == null:
			cur_line += "	"
		else:
			cur_line += str(var2str(cur_instruction.position_override_vector2), "	")
#		if cur_instruction.image == "":
#			cur_line += "	"
#		else:
#			cur_line += var2str(cur_instruction.image)
		cur_line += cur_instruction.image
		lines_to_return.append(cur_line)
		
	
	return PoolStringArray(lines_to_return).join("\n")
	

func _on_UI_load_data(data_string: String):
	# delete previous synapse stuff
	for node in _currently_displayed.values():
		node.queue_free()
	_currently_displayed.clear()
	_selected_instructions.clear()
	
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
#		if next_step_indices.size() == 0:
#			next_step_indices.append(-1)
		var position_override_vector2 = null
		
		# TODO analyzed flag
		
		if data[5] != "":
			position_override_vector2 = str2var(data[5])

		_new_instruction(int(data[0]), _unescape_string(data[1]), int(data[2]), next_step_indices, position_override_vector2, data[6])
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
		
		var seen_instructions: Array = [] # for detecting cyclic references
		
		while cur_instruction != null:
			cur_instruction.rect_position = Vector2(cos(angle), sin(angle)) * ((float(cur_instruction.complexity_layer - 1)*_RING_RADIUS) + _RING_RADIUS/2.0) - cur_instruction.rect_size/2.0
			
			
			if cur_instruction.next_step_indices.size() == 0:
				cur_instruction = null
			else:
				var new_instruction: Instruction = _currently_displayed.get(cur_instruction.next_step_indices[0])
				if seen_instructions.has(new_instruction):
					OS.alert(str("Connection from index ", cur_instruction.index, ", to index ", cur_instruction.next_step_indices[0], ", creates a cyclic reference! Removing the connection..."))
					cur_instruction.next_step_indices.remove(0)
					cur_instruction = null
				seen_instructions.append(new_instruction)
				cur_instruction = new_instruction
	
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

func _new_instruction(index: int, text: String = "placeholder", complexity: int = 1, next_indices: Array = [ ], position_override_vector2 = null, image: String = ""):
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
	cur_instruction.image = image
	cur_instruction.connect("selected", self, "_on_instruction_selected", [cur_instruction])

func _release_focus():
	var focus_owner = get_parent().get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()

func _input(event):
	if event.is_action("editor_escape"):
		_release_focus()

func _deselect_all_instructions() -> void:
	for instruction in _selected_instructions:
			instruction.selected = false
	_selected_instructions.clear()

func _unhandled_input(event):
	if event.is_action_pressed("editor_click"):
		_deselect_all_instructions()
		_release_focus()

	if not _selected_instructions.size() >= 2:
		return
	if event.is_action_pressed("editor_connect_selected"): 
		var to_connect_to: Instruction = _selected_instructions[_selected_instructions.size() - 1]
		for connecting_from in _selected_instructions.slice(0, _selected_instructions.size() - 1):
			if connecting_from == to_connect_to:
				continue
			if not connecting_from.next_step_indices.has(to_connect_to.index):
				connecting_from.next_step_indices.append(to_connect_to.index)
				connecting_from.initialize_visually()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("editor_disconnect_selected"):
#		printt("Selected: ", _selected_instructions)
		for current_instruction in _selected_instructions:
			for target_instruction in _selected_instructions:
#				if current_instruction == target_instruction:
#					continue
				if current_instruction.next_step_indices.has(target_instruction.index):
					current_instruction.next_step_indices.erase(target_instruction.index)
#					_currently_displayed[target_instruction.index].disconnect("moved", current_instruction, "_on_target_moved")
					
			current_instruction.initialize_visually()
		get_tree().set_input_as_handled()

func _on_instruction_selected(instruction_reference: Instruction):
	if not Input.is_key_pressed(KEY_SHIFT):
		_deselect_all_instructions()
	_selected_instructions.append(instruction_reference)

#func _unhandled_input(event):
#
	
