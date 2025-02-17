extends Node

const SCREENSHOT_DIR = "user://screenshots/"

func _ready():
	if not DirAccess.dir_exists_absolute(SCREENSHOT_DIR):
		DirAccess.make_dir_absolute(SCREENSHOT_DIR)

func _input(event):
	if event.is_action_pressed("ui_screenshot"):
		capture()

func capture():
	var dt = Time.get_datetime_dict_from_system()
	var path = "user://screenshots/Screenshot-%04d-%02d-%02d-%02d_%02d_%02d.png" % [
		dt["year"], dt["month"], dt["day"],
		dt["hour"], dt["minute"], dt["second"]
	]
	
	# Wait until the frame has finished before getting the texture.
	await RenderingServer.frame_post_draw
	
	var img = get_viewport().get_texture().get_image()
	
	var err = img.save_png(path)
	
	var full_path = ProjectSettings.globalize_path(path)
	
	if err == OK:
		Console.log("Saved screenshot to %s" % full_path)
	else:
		Console.error("Error saving screenshot (%s)" % var_to_str(full_path), err)
	
	return full_path
