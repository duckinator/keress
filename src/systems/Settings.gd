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
	var file = File.new()
	if not file.file_exists(SETTINGS_FILE):
		return {}
	file.open(SETTINGS_FILE, File.READ)
	var settings = parse_json(file.get_as_text())
	return settings

func _write_to_disk(settings, key):
	var file = File.new()
	file.open(SETTINGS_FILE, File.WRITE)
	Console.log("Updated setting '" + str(key) + "' in " + file.get_path_absolute())
	file.store_string(to_json(settings))
	file.close()
