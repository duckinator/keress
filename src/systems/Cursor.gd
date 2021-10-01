extends Node

func _ready():
	var err = Game.connect("resume", self, "_capture_cursor")
	Console.error_unless_ok("Game.conenct('resume') failed", err)
	
	err = Game.connect("pause", self, "_show_cursor")
	Console.error_unless_ok("Game.connect('pause') failed", err)

	err = MapManager.connect("load_main_menu", self, "_show_cursor")
	Console.error_unless_ok("MapManager.connect('load_main_menu') failed", err)

func _show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
