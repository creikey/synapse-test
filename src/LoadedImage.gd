extends TextureRect


const content_type_beginning: String = "content-type: "

var url: String = "https://static.scientificamerican.com/sciam/cache/file/7A715AD8-449D-4B5A-ABA2C5D92D9B5A21_source.png"

#var is_png: bool = false # will assume jpg if not png

#func _ready():
#	load_image()

func load_image():
	visible = true
	_resize_to_image_height()
	var err: int = $HTTPRequest.request(url)
	if err != OK:
		OS.alert(str("Failed to create HTTP request for url: ", url, " , error: ", err))

func _on_HTTPRequest_request_completed(result, response_code, headers: PoolStringArray, body):
	printt(result, response_code, headers, body)
	printt("Body size: ", body.size())
	
	var filetype_header: String = ""
	for s in headers:
		var lowercase: String = s.to_lower()
		if lowercase.begins_with(content_type_beginning):
			filetype_header = lowercase.lstrip(content_type_beginning).split(",")[0]
			break
	if filetype_header == "":
		filetype_header = "image/jpeg"
		OS.alert(str("Warning - no content header on html response for ", url))

	var image := Image.new()
	var err: int = OK

	match filetype_header:
		"image/jpeg":
			err = image.load_jpg_from_buffer(body)
		"image/png":
			err = image.load_png_from_buffer(body)
		var unknown:
			OS.alert(str("Unknown file header ", unknown))
			return
	if err != OK:
		OS.alert(str("Could not load image buffer from ", url, " , error: ", err))
		return
	texture = ImageTexture.new()
	texture.create_from_image(image)
	
	_resize_to_image_height()

func _resize_to_image_height() -> void:
	var resize_ratio: float = get_parent().rect_size.x / texture.get_size().x
	rect_min_size.y = texture.get_size().y * resize_ratio
	rect_size.y = rect_min_size.y
	var outer_instruction: Control = get_parent().get_parent()
	outer_instruction.set_deferred("rect_size", Vector2(outer_instruction.rect_size.x, 0.0))
#	printt(rect_min_size, rect_size)
