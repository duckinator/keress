extends Control

func _ready():
	var err
	
	Game.playing = false
	$Panels/Start.visible = true
	$Panels/Settings.visible = false
	
	$Panels/Start/Label_Version_Info.text = BuildInfo.summary
	
	$Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer.add_constant_override("separation", 20)

	err = $Panels/Start/Button_New_Game.connect("pressed", self, "game_new")
	assert(err == OK)
	err = $Panels/Start/Button_Settings.connect("pressed", $Panels/Settings, "activate")
	assert(err == OK)
	err = $Panels/Start/Button_Quit.connect("pressed", self, "quit")
	assert(err == OK)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.focus_first_control(self)

func game_new():
	Settings.store("current_level", LevelManager.FIRST_LEVEL)
	hide()
	LevelManager.load_level(LevelManager.get_current_level())

# TODO: Add quit prompt.
func quit():
	Game.quit()
