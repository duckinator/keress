extends Panel

onready var hbox = $ScrollContainer/HBoxContainer
onready var vbox = hbox.get_node('VBoxContainer')
onready var _crosshair = vbox.get_node('CheckButton_Show_Target_Crosshair')
onready var _dot = vbox.get_node('CheckButton_Show_Target_Dot')
onready var _vsync = vbox.get_node('CheckButton_VSync')
onready var _fullscreen = vbox.get_node('CheckButton_Fullscreen')
onready var _debug = vbox.get_node('CheckButton_Debug')
onready var _mob_debug = vbox.get_node('CheckButton_MobDebug')
onready var _controls = vbox.get_node('Button_Controls')
onready var _mouse_sensitivity = vbox.get_node('HSlider_Mouse_Sensitivity')
onready var _joypad_sensitivity = vbox.get_node('HSlider_Joypad_Sensitivity')
onready var _field_of_view = vbox.get_node('HSlider_Field_of_View')

func _ready():
	var err
	
	$InputMapper.visible = false
	
	Game.setup_hbox_vbox(hbox, vbox)

	err = _crosshair.connect("pressed", self, "toggle_target_crosshair")
	assert(err == OK)
	err = _dot.connect("pressed", self, "toggle_target_dot")
	assert(err == OK)
	
	err = _vsync.connect("pressed", self, "toggle_vsync")
	assert(err == OK)
	err = _fullscreen.connect("pressed", self, "toggle_fullscreen")
	assert(err == OK)
	err = _debug.connect("pressed", self, "toggle_debug")
	assert(err == OK)
	err = _mob_debug.connect("pressed", self, "toggle_mob_debug")
	assert(err == OK)
	err = _controls.connect("pressed", $InputMapper, "activate")
	assert(err == OK)
	
	err = _mouse_sensitivity.connect("value_changed", self, "update_mouse_sensitivity")
	assert(err == OK)
	err = _joypad_sensitivity.connect("value_changed", self, "update_joypad_sensitivity")
	assert(err == OK)
	err = _field_of_view.connect("value_changed", self, "update_field_of_view")
	assert(err == OK)
	
	err = $Button_Back.connect("pressed", self, "deactivate")
	assert(err == OK)
	
	load_settings()

func activate():
	show()
	Game.focus_first_control(self)

func deactivate():
	hide()
	Game.focus_first_control(get_parent())

func toggle_target_crosshair():
	Settings.store("show_target_crosshair", _crosshair.pressed)
	load_settings()

func toggle_target_dot():
	Settings.store("show_target_dot", _dot.pressed)
	load_settings()

func toggle_vsync():
	Settings.store("vsync", _vsync.pressed)
	load_settings()

func toggle_fullscreen():
	Settings.store("fullscreen", _fullscreen.pressed)
	load_settings()

func toggle_debug():
	Settings.store("debug", _debug.pressed)
	load_settings()

func toggle_mob_debug():
	Settings.store("mob_debug", _mob_debug.pressed)
	load_settings()

func update_mouse_sensitivity(value):
	Settings.store("mouse_sensitivity", value)
	load_settings()

func update_joypad_sensitivity(value):
	Settings.store("joypad_sensitivity", value)
	load_settings()

func update_field_of_view(value):
	Settings.store("field_of_view", value)
	load_settings()

func load_settings():
	_crosshair.pressed = Settings.fetch("show_target_crosshair")
	_dot.pressed = Settings.fetch("show_target_dot")
	
	_mouse_sensitivity.value = Settings.fetch("mouse_sensitivity")
	_joypad_sensitivity.value = Settings.fetch("joypad_sensitivity")
	_field_of_view.value = Settings.fetch("field_of_view")
	
	_vsync.pressed = Settings.fetch("vsync")
	_fullscreen.pressed = Settings.fetch("fullscreen")
	_debug.pressed = Settings.fetch("debug")
	_mob_debug.pressed = Settings.fetch("mob_debug")
	
	Debug.enabled = _debug.pressed
	Debug.mob_debug_enabled = _mob_debug.pressed
	OS.window_fullscreen = _fullscreen.pressed
	OS.vsync_enabled = _vsync.pressed
