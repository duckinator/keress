extends Node

onready var enabled = "--debug" in OS.get_cmdline_args()

func _process(_delta):
	if enabled and Game.playing:
		Game.add_debug_display()
	else:
		Game.remove_debug_display()
