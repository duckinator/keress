extends Node

var _enabled
var enabled = false setget _set_enabled, _get_enabled

func _ready():
	pass

func print(text):
	if _enabled:
		print(text)

func log(text):
	if _enabled:
		Console.debug(text)

func _set_enabled(val):
	_enabled = val
	if _enabled:
		Globals.add_debug_display()
	else:
		Globals.remove_debug_display()

func _get_enabled(val):
	return _enabled