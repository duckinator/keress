extends Node

onready var enabled = "--debug" in OS.get_cmdline_args()
onready var mob_debug_enabled = "--debug-mobs" in OS.get_cmdline_args()

func _process(_delta):
	if enabled and Game.playing:
		Game.add_debug_display()
	else:
		Game.remove_debug_display()
	
	if mob_debug_enabled and Game.playing:
		Game.add_mob_debug_display()
	else:
		Game.remove_mob_debug_display()
