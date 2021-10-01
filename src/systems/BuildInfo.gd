extends Node

var defaults = {
	"version": null,
	"build_hash": null,
	"cirrus_task_id": null,
}

onready var metadata = load_metadata()
onready var version = normalize(metadata.result["version"])
onready var build_hash = normalize(metadata.result["build_hash"])
onready var cirrus_task_id = normalize(metadata.result["cirrus_task_id"])

var summary = null

var source_url = null
var cirrus_url = null

func _ready():
	if cirrus_task_id != null:
		cirrus_url = "https://cirrus-ci.com/task/" + cirrus_task_id
		Console.log("Build logs: " + cirrus_url)
	
	if version == null:
		Console.log("Version not found. This usually means it's run from the editor.")
	else:
		Console.log("Game version: " + version)
	
	if build_hash == null:
		Console.log("No build information is available. This usually means it's run from the editor.")
	else:
		source_url = "https://github.com/duckinator/keress/tree/" + build_hash
		Console.log("Source for this build: " + source_url)
	
	if version and build_hash:
		summary = "Version: " + version + " (" + build_hash + ")"
	else:
		summary = "Version info unavailable. Likely running from Godot editor."

func normalize(data):
	if data == "":
		return null
	else:
		return data

func load_metadata():
	var path = "res://build_info.json"
	var file = File.new()
	
	if not file.file_exists(path):
		return {"result": defaults}
	
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse(content)
