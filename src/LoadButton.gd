extends Button

func _ready():
	if OS.get_name() == "HTML5":
		text = "Load from textbox above"
	else:
		text = "Load from clipboard"
