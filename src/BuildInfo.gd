extends Node

var defaults = {
	"build_id": null,
	"build_hash": null,
}

onready var metadata = load_metadata()
onready var build_id = metadata["build_id"]
onready var build_hash = metadata["build_hash"]

func _ready():
	if build_id == null:
		Console.log("Build ID not found. This is expected for unofficial builds.")
	else:
		Console.log("Build ID: " + build_id)
	
	if build_hash == null:
		Console.log("No build information is available. This usually means it's run from the editor.")
	else:
		Console.log("Source for this build: https://github.com/duckinator/keress/tree/" + build_hash)

func load_metadata():
	var path = "res://build_info.json"
	var file = File.new()
	
	if not file.file_exists(path):
		return defaults
	
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse(content)