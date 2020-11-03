extends Control

class_name Instruction

signal selected
signal moved

const SELECTED_PANEL_CONTAINER: StyleBox = preload("res://Styleboxes/SelectedPanelContainer.tres")

var index: int = 1
var step_text: String = ""
var complexity_layer: int = 0
var next_step_indices: Array = []
var analyzed_bool = null
var position_override_vector2 = null

var currently_displayed: Dictionary = {}
var _instruction_to_line_pointing_to_it: Dictionary = {}
var selected: bool = false setget set_selected

func set_selected(new_selected):
	if new_selected and not selected:
		emit_signal("selected")
	selected = new_selected
	if selected:
		add_stylebox_override("panel", SELECTED_PANEL_CONTAINER)
	else:
		add_stylebox_override("panel", null)

func get_centerpoint() -> Vector2:
	return rect_global_position + rect_size/2.0

func initialize_visually():
	$V/TextEdit.text = step_text
	$V/IndexNumber.text = str(index)
	rect_size = Vector2(300, 200)
	for c in $ConnectionLines.get_children():
		c.queue_free()
	for instruction in _instruction_to_line_pointing_to_it.keys():
		instruction.disconnect("moved", self, "_on_target_moved")
	_instruction_to_line_pointing_to_it.clear()
	
	if not next_step_indices.size() > 0:
		return

	var made_first_line: bool = false
	for cur_index in next_step_indices:
		if cur_index == -1:
			continue
		if not currently_displayed.has(cur_index):
			OS.alert(str("Warning: Index ", index, " has invalid next step index ", cur_index, ", points to nothing!"))
			continue
	
		var cur_line: ConnectionLine
		if not made_first_line:
			cur_line = preload("res://ConnectionLine/ConnectionLine.tscn").instance()
			made_first_line = true
		else:
			cur_line = preload("res://ConnectionLine/TangentConnectionLine.tscn").instance()
		$ConnectionLines.add_child(cur_line)
		
		var target_instruction: Instruction = currently_displayed[cur_index]
		if not target_instruction.is_connected("moved", self, "_on_target_moved"):
			target_instruction.connect("moved", self, "_on_target_moved")
		
		_instruction_to_line_pointing_to_it[target_instruction] = cur_line
		
		_update_line_target(target_instruction)

func _input(event):
	if event is InputEventMouseMotion and selected and Input.is_action_pressed("editor_click"):
		var relative_movement: Vector2 = event.relative
		# transform from viewport space to local space
		relative_movement = relative_movement / get_viewport().canvas_transform.get_scale()
		rect_position += relative_movement
		position_override_vector2 = rect_global_position
		emit_signal("moved", self)
		for instruction in _instruction_to_line_pointing_to_it.keys():
			_update_line_target(instruction)

func _on_target_moved(instruction_that_moved: Instruction):
	_update_line_target(instruction_that_moved)

func _on_TextEdit_text_changed():
	step_text = $V/TextEdit.text

func _update_line_target(instruction: Instruction):
	_instruction_to_line_pointing_to_it[instruction].target = instruction.get_centerpoint()

func _on_Instruction_resized():
	$ConnectionLines.position = rect_size/2.0


func _on_Instruction_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		self.selected = true
