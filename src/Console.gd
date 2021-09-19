extends Node

const CONSOLE_SCENE = preload("res://console/Console.tscn")

var _console

var visible setget , _get_visible

func _ready():
	_console = CONSOLE_SCENE.instance()
	add_child(_console)
	hide()
	self.log("Config files are located in " + str(OS.get_user_data_dir()))

func _get_visible():
	return _console.visible

func _line_prefix():
	var dt = OS.get_datetime()
	var hour = str(dt["hour"]).pad_zeros(2)
	var minute = str(dt["minute"]).pad_zeros(2)
	var second = str(dt["second"]).pad_zeros(2)
	return "[" + hour + ":" + minute + ":" + second + "] "

func hide():
	_console.set_enabled(false)

func show():
	_console.set_enabled(true)

func toggle():
	if visible:
		hide()
	else:
		show()

func debug(text):
	if Debug.enabled:
		log("DEBUG: " + text)

func error(text):
	log("ERROR: " + text)

func warn(text):
	log("WARNING: " + text)

func log(text):
	var line = _line_prefix() + text
	_console.log_line(line)
	print(line)

func clear():
	_console.clear()
