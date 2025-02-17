extends Control

func _ready():
	var err
	
	$Panels/Start.visible = true
	$Panels/Settings.visible = false
	
	$Panels/Start/Label_Version_Info.text = BuildInfo.summary
	
	$Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer.add_theme_constant_override("separation", 20)

	err = $Panels/Start/Button_New_Game.connect("pressed", Callable(self, "game_new"))
	Console.error_unless_ok("$Button_New_game.connect('pressed') failed", err)
	err = $Panels/Start/Button_Settings.connect("pressed", Callable($Panels/Settings, "activate"))
	Console.error_unless_ok("$Button_Settings.connect('pressed') failed", err)
	err = $Panels/Start/Button_Quit.connect("pressed", Callable(self, "quit"))
	Console.error_unless_ok("$Button_Quit.connect('pressed') failed", err)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	activate()

func activate():
	$Panels/Start/Button_New_Game.grab_focus()

func game_new():
	hide()
	MapManager.load_map()

# TODO: Add quit prompt.
func quit():
	Game.quit()
