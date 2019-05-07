extends Control

func _ready():
	var err
	
	Game.playing = false
	$Panels/Start.visible = true
	$Panels/Settings.visible = false

	err = $Panels/Start/Button_Continue.connect("pressed", self, "game_continue")
	assert(err == OK)
	err = $Panels/Start/Button_New_Game.connect("pressed", self, "game_new")
	assert(err == OK)
	err = $Panels/Start/Button_Settings.connect("pressed", self, "panel_select", ["Settings"])
	assert(err == OK)
	err = $Panels/Start/Button_Quit.connect("pressed", self, "quit")
	assert(err == OK)

	err = $Panels/Settings/Button_Back.connect("pressed", self, "panel_select", ["Start"])
	assert(err == OK)
	err = $Panels/Settings/CheckButton_VSync.connect("pressed", self, "toggle_vsync")
	assert(err == OK)
	err = $Panels/Settings/CheckButton_Fullscreen.connect("pressed", self, "toggle_fullscreen")
	assert(err == OK)
	err = $Panels/Settings/CheckButton_Debug.connect("pressed", self, "toggle_debug")
	assert(err == OK)

	$Panels/Settings/CheckButton_VSync.pressed = Settings.fetch("vsync", true)
	$Panels/Settings/CheckButton_Fullscreen.pressed = Settings.fetch("fullscreen", false)
	$Panels/Settings/CheckButton_Debug.pressed = Settings.fetch("debug", false)

	$Panels/Start/Button_Continue.disabled = not Settings.fetch("has_played")

	load_settings()
	
	panel_select("Start")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func game_continue():
	panel_select("none")
	Game.load_level(Game.get_current_level())

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

func toggle_vsync():
	Settings.store("vsync", $Panels/Settings/CheckButton_VSync.pressed)
	load_settings()

func toggle_fullscreen():
	Settings.store("fullscreen", $Panels/Settings/CheckButton_Fullscreen.pressed)
	load_settings()

func toggle_debug():
	Settings.store("debug", $Panels/Settings/CheckButton_Debug.pressed)
	load_settings()

func load_settings():
	Debug.enabled = $Panels/Settings/CheckButton_Debug.pressed
	OS.window_fullscreen = $Panels/Settings/CheckButton_Fullscreen.pressed
	OS.vsync_enabled = $Panels/Settings/CheckButton_VSync.pressed
	#$Panels/Settings/HSlider_Joypad_Sensitivity = Globals.joypad_sensitivity
	#$Panels/Settings/HSlider_Mouse_Sensitivity = Globals.mouse_sensitivity