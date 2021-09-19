extends Node

var enabled = false setget _set_enabled, _get_enabled

var mob_debug_enabled = false setget _set_mob_debug_enabled, _get_mob_debug_enabled

func _ready():
	if "--debug" in OS.get_cmdline_args():
		_set_enabled(true)
	
	if "--debug-mobs" in OS.get_cmdline_args():
		_set_mob_debug_enabled(true)

func _set_enabled(val):
	if enabled == val:
		return
	
	if val:
		Console.log("!!! Enabling debug output.")
	else:
		Console.log("!!! Disabling debug output.")
	
	enabled = val

func _get_enabled():
	return enabled

func _set_mob_debug_enabled(val):
	if mob_debug_enabled == val:
		return
	mob_debug_enabled = val

func _get_mob_debug_enabled():
	return mob_debug_enabled

func _process(_delta):
	if enabled and Game.playing:
		Game.add_debug_display()
	else:
		Game.remove_debug_display()
	
	if mob_debug_enabled and Game.playing:
		Game.add_mob_debug_display()
	else:
		Game.remove_mob_debug_display()
