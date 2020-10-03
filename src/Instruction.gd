extends Control

class_name Instruction

var index: int = 1
var step_text: String = ""
var complexity_layer: int = 0
var next_step_index: int = 90
var analyzed_bool = null
var position_override_vector2 = null

func initialize_visually():
	$V/TextEdit.text = step_text
	rect_size = Vector2(300, 200)

func _input(event):
	if event is InputEventMouseMotion and $V/MoveButton.pressed:
		var relative_movement: Vector2 = event.relative
		# transform from viewport space to local space
		relative_movement = relative_movement / get_viewport().canvas_transform.get_scale()
		rect_position += relative_movement
		position_override_vector2 = rect_global_position

func _on_TextEdit_text_changed():
	step_text = $V/TextEdit.text
