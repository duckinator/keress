extends Control

# TODO: Determine at what point these become an actual problem.
const FRAME_TIME_WARN = 0.1
const PHYSICS_TIME_WARN = 0.1

onready var label = $Panel/RichTextLabel

func _process(_delta):
	var player_position = Game.get_player().translation.round()
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var ftime_str = "%.2f" % frame_time
	var ptime_str = "%.2f" % physics_time
	
	if frame_time > FRAME_TIME_WARN:
		ftime_str = "[color=red]" + ftime_str + "[/color]"
	if physics_time > PHYSICS_TIME_WARN:
		ptime_str = "[color=red]" + ptime_str + "[/color]"
	
	var lines = [
		"FPS:    %s" % [fps],
		"Timing: frame=%s, physics=%s" % [ftime_str, ptime_str],
		"",
		"Player position: " + str(player_position),
		"",
		"AOIs:    " + PoolStringArray(AreasOfInterest.areas).join(", ")
	]
	
	var mobs = Entities.mobs
	for idx in len(mobs):
		var mob = mobs[idx]
		if mob == null:
			lines.append("! mobs[" + str(idx) + "] is null.")
		else:
			lines.append(mob.name + " #" + str(idx) + ": " + str(mob.target))
	
	label.clear()
	for idx in range(0, len(lines)):
		label.append_bbcode(lines[idx])
		if idx < (len(lines) - 1):
			label.newline()
