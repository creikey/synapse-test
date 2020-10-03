extends Button

func _ready():
	if OS.get_name() == "HTML5":
		text = "To textbox above"
	else:
		text = "To clipboard"
