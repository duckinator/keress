extends Node

const SETTINGS_FILE = "user://settings.json"

#func _ready():
#	pass

func store(key, val):
	var settings = _read_from_disk()
	settings[key] = val
	_write_to_disk(settings)
	return val

func fetch(key, default=null):
	var settings = _read_from_disk()
	if not key in settings:
		return default
	return settings[key]

func _read_from_disk():
	var file = File.new()
	if not file.file_exists(SETTINGS_FILE):
		return {}
	file.open(SETTINGS_FILE, File.READ)
	var settings = parse_json(file.get_as_text())
	return settings

func _write_to_disk(settings):
	var file = File.new()
	file.open(SETTINGS_FILE, File.WRITE)
	print("Saved: " + file.get_path())
	file.store_string(to_json(settings))
	file.close()