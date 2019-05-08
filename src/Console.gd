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
	_console.log("DEBUG: " + text)

func error(text):
	_console.log("ERROR: " + text)

func warn(text):
	_console.log("WARNING: " + text)

func log(text):
	_console.log(text)

func clear():
	_console.clear()