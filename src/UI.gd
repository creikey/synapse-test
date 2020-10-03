extends CanvasLayer

signal load_data(data_string)

export (NodePath) var _synapse_path

onready var _synapse: Synapse = get_node(_synapse_path)


func _on_LoadButton_pressed():
	var loaded_text: String = ""
	if OS.get_name() == "HTML5":
		# textbox above the game window for pasting in
		loaded_text = JavaScript.eval("document.getElementById(\"textbox\").value")
	else:
		loaded_text = OS.clipboard
	emit_signal("load_data", loaded_text)

func _on_ToClipButton_pressed():
	OS.clipboard = _synapse.get_data()
