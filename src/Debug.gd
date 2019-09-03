extends Node

var enabled = false setget _set_enabled, _get_enabled

func _ready():
	if "--debug" in OS.get_cmdline_args():
		_set_enabled(true)

func print(text):
	if enabled:
		print(text)

func log(text):
	if enabled:
		Console.debug(text)

func _set_enabled(val):
	enabled = val

func _process(delta):
	if enabled and Game.playing:
		Game.add_debug_display()
	else:
		Game.remove_debug_display()

func _get_enabled():
	return enabled