extends Node

func _ready():
	self.log("Config files are located in " + str(OS.get_user_data_dir()))

func _line_prefix():
	var dt = OS.get_datetime()
	var hour = str(dt["hour"]).pad_zeros(2)
	var minute = str(dt["minute"]).pad_zeros(2)
	var second = str(dt["second"]).pad_zeros(2)
	return "[" + hour + ":" + minute + ":" + second + "] "

func debug(text):
	if Debug.enabled:
		_log("DEBUG", text)

func error(text):
	_log("ERROR", text)

func warn(text):
	_log("WARN ", text)

func info(text):
	_log("INFO ", text)

func log(text):
	info(text)

func _log(type, text):
	print("[" + type + "] " + _line_prefix() + text)
