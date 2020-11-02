extends HBoxContainer

var tools: Array = [
	ToolPointer,
]

var tool_buttons: Array = []

var current_tool: ToolBase = ToolBase.new()

func _ready():
	# instance each class in array
	for i in tools.size():
		tools[i] = tools[i].new()
	
	var i: int = 0
	for tool_object in tools:
		var new_button: Button = preload("res://UI/ToolButton.tscn").instance()
		add_child(new_button)
		tool_buttons.append(new_button)
		new_button.init_from_tool(tool_object)
		new_button.connect("pressed", self, "_set_tool", [i])
		i += 1
	
	_set_tool(0)

func _set_tool(tool_index: int):
	for t in tool_buttons:
		t.pressed = false
	var current_button: Button = tool_buttons[tool_index]
	current_button.pressed = true
	current_tool = current_button.tool_object

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode >= KEY_1 and event.scancode <= KEY_9:
		var new_tool_index = event.scancode - KEY_0 - 1
		if new_tool_index >= 0 and new_tool_index < tool_buttons.size():
			_set_tool(new_tool_index)
