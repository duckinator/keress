extends Control

onready var vbox = $Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer
onready var _vsync = vbox.get_node('CheckButton_VSync')
onready var _fullscreen = vbox.get_node('CheckButton_Fullscreen')
onready var _debug = vbox.get_node('CheckButton_Debug')
onready var _controls = vbox.get_node('Button_Controls')
onready var _mouse_sensitivity = vbox.get_node('HSlider_Mouse_Sensitivity')
onready var _joypad_sensitivity = vbox.get_node('HSlider_Joypad_Sensitivity')
onready var _field_of_view = vbox.get_node('HSlider_Field_of_View')

func _ready():
	var err
	
	Game.playing = false
	$Panels/Start.visible = true
	$Panels/Settings.visible = false
	
	$Panels/Settings/ScrollContainer/HBoxContainer/VBoxContainer.add_constant_override("separation", 20)

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
	
	err = _vsync.connect("pressed", self, "toggle_vsync")
	assert(err == OK)
	err = _fullscreen.connect("pressed", self, "toggle_fullscreen")
	assert(err == OK)
	err = _debug.connect("pressed", self, "toggle_debug")
	assert(err == OK)
	err = _controls.connect("pressed", self, "panel_select", ["InputMapper"])
	assert(err == OK)
	
	err = $Panels/InputMapper.done.connect("pressed", self, "panel_select", ["Settings"])
	assert(err == OK)

	_vsync.pressed = Settings.fetch("vsync", true)
	_fullscreen.pressed = Settings.fetch("fullscreen", false)
	_debug.pressed = Settings.fetch("debug", false)

	$Panels/Start/Button_Continue.disabled = not Settings.fetch("has_played")

	$Panels/InputMapper.load_config()
	load_settings()

	err = _mouse_sensitivity.connect("value_changed", self, "update_mouse_sensitivity")
	assert(err == OK)
	err = _joypad_sensitivity.connect("value_changed", self, "update_joypad_sensitivity")
	assert(err == OK)
	
	panel_select("Start")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

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

func toggle_vsync():
	Settings.store("vsync", _vsync.pressed)
	load_settings()

func toggle_fullscreen():
	Settings.store("fullscreen", _fullscreen.pressed)
	load_settings()

func toggle_debug():
	Settings.store("debug", _debug.pressed)
	load_settings()

func update_mouse_sensitivity(value):
	Settings.store("mouse_sensitivity", value)
	load_settings()

func update_joypad_sensitivity(value):
	Settings.store("joypad_sensitivity", value)
	load_settings()

func load_settings():
	Debug.enabled = _debug.pressed
	OS.window_fullscreen = _fullscreen.pressed
	OS.vsync_enabled = _vsync.pressed
	_mouse_sensitivity.value = Game.get_joypad_sensitivity()
	_joypad_sensitivity.value = Game.get_mouse_sensitivity()