extends Node

onready var enabled = "--debug" in OS.get_cmdline_args()

func _process(_delta):
	# If debug mode is enabled, we're playing the game, and there's no
	# debug display, add one.
	if enabled and Game.playing and Game.debug_display == null:
		Game.add_debug_display()
