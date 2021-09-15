extends Control

func _ready():
	var err
	
	Game.playing = false
	$Panels/Start.visible = true
	$Panels/Settings.visible = false
	
	$Panels/Start/Label_Version_Info.text = BuildInfo.summary
	
	$Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer.add_constant_override("separation", 20)

	err = $Panels/Start/Button_Continue.connect("pressed", self, "game_continue")
	assert(err == OK)
	err = $Panels/Start/Button_New_Game.connect("pressed", self, "game_new")
	assert(err == OK)
	err = $Panels/Start/Button_Settings.connect("pressed", $Panels/Settings, "activate")
	assert(err == OK)
	err = $Panels/Start/Button_Quit.connect("pressed", self, "quit")
	assert(err == OK)
	
	$Panels/Start/Button_Continue.disabled = not Settings.fetch("has_played")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.focus_first_control(self)

func game_continue():
	hide()
	LevelManager.load_level(LevelManager.get_current_level())

func game_new():
	Settings.store("has_played", true)
	Settings.store("current_level", LevelManager.FIRST_LEVEL)
	game_continue()

# TODO: Add quit prompt.
func quit():
	Game.quit()
