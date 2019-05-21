extends Control

func _ready():
	var err
	
	Game.playing = false
	$Panels/Start.visible = true
	$Panels/Settings.visible = false
	$Panels/InputMapper.visible = false
	
	$Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer.add_constant_override("separation", 20)

	err = $Panels/Start/Button_Continue.connect("pressed", self, "game_continue")
	assert(err == OK)
	err = $Panels/Start/Button_New_Game.connect("pressed", self, "game_new")
	assert(err == OK)
	err = $Panels/Start/Button_Settings.connect("pressed", self, "panel_select", ["Settings"])
	assert(err == OK)
	err = $Panels/Start/Button_Quit.connect("pressed", self, "quit")
	assert(err == OK)
	
	# TODO: Move this to SettingsMenu, and make it just hide itself.
	err = $Panels/Settings/Button_Back.connect("pressed", self, "panel_select", ["Start"])
	assert(err == OK)
	
	# TODO: Move this to InputMapper, and make it just hide itself.
	err = $Panels/InputMapper.done.connect("pressed", self, "panel_select", ["Settings"])
	assert(err == OK)
	
	$Panels/Start/Button_Continue.disabled = not Settings.fetch("has_played")
	
	# TODO: Move this to InputMapper.
	$Panels/InputMapper.load_config()
	
	panel_select("Start")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func game_continue():
	panel_select("none")
	Game.load_level(Game.get_current_level(), true)

func game_new():
	Settings.store("has_played", true)
	Settings.store("current_level", Game.FIRST_LEVEL)
	game_continue()

# REQUIREMENT: There should be no panel named "none".
func panel_select(selected):
	var active = null
	for panel in $Panels.get_children():
		panel.visible = (panel.name == selected)
		if panel.visible:
			active = panel
	
	if not active:
		return null
	
	Game.focus_first_control(active)
	
	return active

# TODO: Add quit prompt.
func quit():
	Game.quit()
