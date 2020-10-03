extends LineEdit

class_name Synapse

func get_data() -> String:
	return text


func _on_UI_load_data(data_string: String):
	text = data_string
