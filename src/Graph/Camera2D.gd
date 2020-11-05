extends Camera2D

const ZOOM_MIN = 0.3
const ZOOM_MAX = 8.0
const ZOOM_STEP = 0.25
const FOCUS_PADDING = 1500.0

var target_zoom: float = 1.0 setget set_target_zoom

func set_target_zoom(new_target_zoom):
	target_zoom = clamp(new_target_zoom, ZOOM_MIN, ZOOM_MAX)

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("editor_pan"):
		global_position -= event.relative*self.zoom.x
		global_position.x = clamp(global_position.x, self.limit_left, self.limit_right)
		global_position.y = clamp(global_position.y, self.limit_top, self.limit_bottom)
	elif event.is_action_pressed("editor_zoom_in"):
		self.target_zoom -= ZOOM_STEP
	elif event.is_action_pressed("editor_zoom_out"):
		self.target_zoom += ZOOM_STEP

func _ready():
	yield(get_tree(), "idle_frame")
	global_position = get_parent().rect_size/2.0

func _process(_delta):
	self.zoom.x = lerp(self.zoom.x, target_zoom, 0.25)
	self.zoom.y = self.zoom.x
