extends Node

var enabled = false setget _set_enabled, _get_enabled

func _ready():
	pass

func print(text):
	if enabled:
		print(text)

func log(text):
	if enabled:
		Console.debug(text)

func _set_enabled(val):
	enabled = val
	if enabled:
		Globals.add_debug_display()
	else:
		Globals.remove_debug_display()

func _get_enabled():
	return enabled