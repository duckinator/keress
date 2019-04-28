extends Control

var os
var engine

var label
func _ready():
	label = $Panel/RichTextLabel
	os = OS.get_name()
	engine = Engine.get_version_info()["string"]

func _process(delta):
	var level = "(None)"
	var position = "(None)"
	
	var scene = get_tree().current_scene
	if scene.has_method("get_player"):
		var pos = scene.get_player().translation.round()
		level = str(scene.current_level)
		position = str(pos)
	
	var lines = [
		"System:   " + OS.get_name(),
		"Engine:   Godot " + Engine.get_version_info()["string"],
		"FPS:      " + str(Engine.get_frames_per_second()),
		"Level:    " + level,
		"Position: " + position,
	]
	
	label.clear()
	for idx in range(0, len(lines)):
		label.add_text(lines[idx])
		if idx < (len(lines) - 1):
			label.newline()