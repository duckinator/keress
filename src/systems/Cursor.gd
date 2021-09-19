extends Node

func _ready():
	var err = Game.connect("resume", self, "_capture_cursor")
	if err != OK:
		Console.log(str(err))
	
	err = Game.connect("pause", self, "_show_cursor")
	if err != OK:
		Console.log(str(err))

	err = MapManager.connect("load_main_menu", self, "_show_cursor")
	if err != OK:
		Console.log(str(err))

func _show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
