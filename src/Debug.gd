extends Node

var enabled = false

var mob_debug_enabled = false

func _ready():
	if "--debug" in OS.get_cmdline_args():
		enabled = true
	
	if "--debug-mobs" in OS.get_cmdline_args():
		mob_debug_enabled = true

func _process(_delta):
	if enabled and Game.playing:
		Game.add_debug_display()
	else:
		Game.remove_debug_display()
	
	if mob_debug_enabled and Game.playing:
		Game.add_mob_debug_display()
	else:
		Game.remove_mob_debug_display()
