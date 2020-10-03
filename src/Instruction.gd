extends Control

class_name Instruction

signal moved

var index: int = 1
var step_text: String = ""
var complexity_layer: int = 0
var next_step_index: int = 90
var analyzed_bool = null
var position_override_vector2 = null

var currently_displayed: Dictionary = {}

func get_centerpoint() -> Vector2:
	return rect_global_position

func initialize_visually():
	$V/TextEdit.text = step_text
	rect_size = Vector2(300, 200)
	if next_step_index != -1:
		if not currently_displayed.has(next_step_index):
			OS.alert(str("Warning: Index ", index, " has invalid next step index ", next_step_index, ", points to nothing!"))
			$Line2D.visible = false
			return
		currently_displayed[next_step_index].connect("moved", self, "_on_target_moved")
		_update_line_target()
	else:
		$Line2D.visible = false

func _input(event):
	if event is InputEventMouseMotion and $V/MoveButton.pressed:
		var relative_movement: Vector2 = event.relative
		# transform from viewport space to local space
		relative_movement = relative_movement / get_viewport().canvas_transform.get_scale()
		rect_position += relative_movement
		position_override_vector2 = rect_global_position
		emit_signal("moved")
		_update_line_target()

func _on_target_moved():
	_update_line_target()

func _on_TextEdit_text_changed():
	step_text = $V/TextEdit.text

func _update_line_target():
#	currently_displayed[next_step_index].connect("moved", self, )
	$Line2D.points[1] = get_global_transform().affine_inverse().xform(currently_displayed[next_step_index].get_centerpoint())

func _on_Instruction_resized():
	$Line2D.position = rect_size/2.0
