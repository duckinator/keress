extends Node

var defaults = {
	"build_id": "(unknown)",
	"build_hash": "(unknown)",
}

onready var metadata = load_metadata()
onready var build_id = metadata["build_id"]
onready var build_hash = metadata["build_hash"]

func load_metadata():
	var path = "res://build_info.json"
	var file = File.new()
	
	if not file.file_exists(path):
		return defaults
	
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse(content)