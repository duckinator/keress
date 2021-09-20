extends Node

func _ready():
	info("Config files are located in " + str(OS.get_user_data_dir()))
	info("System: " + OS.get_name())
	info("Engine: Godot " + Engine.get_version_info()["string"])

func _line_prefix():
	var dt = OS.get_datetime()
	var hour = str(dt["hour"]).pad_zeros(2)
	var minute = str(dt["minute"]).pad_zeros(2)
	var second = str(dt["second"]).pad_zeros(2)
	return "[" + hour + ":" + minute + ":" + second + "] "

func debug(text):
	if Debug.enabled:
		_log("DEBUG", text)

func error_unless_ok(prefix, err=null):
	if err != OK:
		error(prefix, err)

func error(prefix, err=null, capture=true):
	if capture:
		BugReporter.capture(prefix, err, true)
	if err == null:
		_log("ERROR", prefix)
	else:
		_log("ERROR", prefix + ": " + var2str(err))

func warn(text):
	_log("WARN ", text)

func info(text):
	_log("INFO ", text)

func log(text):
	info(text)

func _log(type, text):
	print("[" + type + "] " + _line_prefix() + text)
