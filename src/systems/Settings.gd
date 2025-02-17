extends Node

const SETTINGS_FILE = "user://settings.json"

const DEFAULTS = {
	"mouse_sensitivity": 20,
	"joypad_sensitivity": 20,
	"field_of_view": 80,
	
	"vsync": false,
	"fullscreen": false,
	"debug": false,
	
	"gun_on_left": false,
}

func store(key, val):
	var settings = _read_from_disk()
	settings[key] = val
	_write_to_disk(settings, key)
	return val

func fetch(key):
	var settings = _read_from_disk()
	if not key in settings:
		return DEFAULTS[key]
	return settings[key]

func _read_from_disk():
	if not FileAccess.file_exists(SETTINGS_FILE):
		return {}
	var text = FileAccess.get_file_as_string(SETTINGS_FILE)
	return JSON.parse_string(text)

func _write_to_disk(settings, key):
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	Console.log("Updated setting '" + str(key) + "' in " + file.get_path_absolute())
	file.store_string(JSON.stringify(settings))
	file.close()
