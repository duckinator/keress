extends Node

const SCREENSHOT_DIR = "user://screenshots/"

func _ready():
	var dir = Directory.new()
	if not dir.dir_exists(SCREENSHOT_DIR):
		dir.make_dir(SCREENSHOT_DIR)

func _input(event):
	if event.is_action_pressed("ui_screenshot"):
		capture()

func capture():
	var dt = OS.get_datetime()
	var path = "user://screenshots/Screenshot-%04d-%02d-%02d-%02d_%02d_%02d.png" % [
		dt["year"], dt["month"], dt["day"],
		dt["hour"], dt["minute"], dt["second"]
	]
	
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")
	
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	
	var err = img.save_png(path)
	
	var file = File.new()
	file.open(path, File.READ)
	var full_path = file.get_path_absolute()
	
	if err == OK:
		Console.log("Saved screenshot to %s" % full_path)
	else:
		Console.error("Error saving screenshot (%s)" % var2str(full_path), err)
	
	return full_path
