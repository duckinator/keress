extends Control

var start_menu
var options_menu

var panels = null

func _ready():
	$Panels/Start.visible = true
	$Panels/Settings.visible = false

	$Panels/Start/Button_Continue.connect("pressed", self, "game_continue")
	$Panels/Start/Button_New_Game.connect("pressed", self, "game_new")
	$Panels/Start/Button_Settings.connect("pressed", self, "panel_select", ["Settings"])
	$Panels/Start/Button_Quit.connect("pressed", self, "quit")

	$Panels/Settings/Button_Back.connect("pressed", self, "panel_select", ["Start"])
	$Panels/Settings/CheckButton_VSync.connect("pressed", self, "toggle_vsync")
	$Panels/Settings/CheckButton_Fullscreen.connect("pressed", self, "toggle_fullscreen")
	$Panels/Settings/CheckButton_Debug.connect("pressed", self, "toggle_debug")

	$Panels/Settings/CheckButton_VSync.pressed = Settings.fetch("vsync", true)
	$Panels/Settings/CheckButton_Fullscreen.pressed = Settings.fetch("fullscreen", false)
	$Panels/Settings/CheckButton_Debug.pressed = Settings.fetch("debug", false)
	
	Globals.set_debug($Panels/Settings/CheckButton_Debug.pressed)

	#$Panels/Settings/HSlider_Joypad_Sensitivity = Globals.joypad_sensitivity
	#$Panels/Settings/HSlider_Mouse_Sensitivity = Globals.mouse_sensitivity

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func game_continue():
	panel_select("none")
	print("game continue")

func game_new():
	panel_select("none")
	print("game new")

# REQUIREMENT: There should be no panel named "none".
func panel_select(selected):
	for panel in $Panels.get_children():
		panel.visible = (panel.name == selected)

# TODO: Add quit prompt.
func quit():
	get_tree().quit()

func toggle_vsync():
	Settings.store("vsync", $Panels/Settings/CheckButton_VSync.pressed)

func toggle_fullscreen():
	Settings.store("fullscreen", $Panels/Settings/CheckButton_Fullscreen.pressed)

func toggle_debug():
	var debug = $Panels/Settings/CheckButton_Debug.pressed
	Settings.store("debug", debug)
	Globals.set_debug(debug)