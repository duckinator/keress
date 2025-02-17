extends Node

func _ready():
	var err = Game.resuming.connect(Callable(self, "_capture_cursor"))
	Console.error_unless_ok("Game.resuming.connect() failed", err)
	
	err = Game.pausing.connect(Callable(self, "_show_cursor"))
	Console.error_unless_ok("Game.pausing.connect() failed", err)

	err = MapManager.load_main_menu.connect(Callable(self, "_show_cursor"))
	Console.error_unless_ok("MapManager.load_main_menu.connect() failed", err)

func _show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
