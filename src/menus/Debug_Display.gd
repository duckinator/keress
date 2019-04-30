extends Control

# TODO: Determine at what point these become an actual problem.
const FRAME_TIME_WARN = 0.1
const PHYSICS_TIME_WARN = 0.1

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
	
	var fps = str(Engine.get_frames_per_second())
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var ftime_str = "%.2f" % frame_time
	var ptime_str = "%.2f" % physics_time
	
	if frame_time > FRAME_TIME_WARN:
		ftime_str = "[color=red]" + ftime_str + "[/color]"
	if physics_time > PHYSICS_TIME_WARN:
		ptime_str = "[color=red]" + ptime_str + "[/color]"
	
	var lines = [
		"System:   " + OS.get_name(),
		"Engine:   Godot " + Engine.get_version_info()["string"],
		#"FPS:      " + fps,
		"Timing:   frame=%s, physics=%s" % [ftime_str, ptime_str],
		"Level:    " + level,
		"Position: " + position,
	]
	
	label.clear()
	for idx in range(0, len(lines)):
		label.append_bbcode(lines[idx])
		if idx < (len(lines) - 1):
			label.newline()