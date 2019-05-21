extends Panel

onready var vbox = $ScrollContainer/HBoxContainer/VBoxContainer
onready var _vsync = vbox.get_node('CheckButton_VSync')
onready var _fullscreen = vbox.get_node('CheckButton_Fullscreen')
onready var _debug = vbox.get_node('CheckButton_Debug')
onready var _controls = vbox.get_node('Button_Controls')
onready var _mouse_sensitivity = vbox.get_node('HSlider_Mouse_Sensitivity')
onready var _joypad_sensitivity = vbox.get_node('HSlider_Joypad_Sensitivity')
onready var _field_of_view = vbox.get_node('HSlider_Field_of_View')

func _ready():
	var err
	
	err = _vsync.connect("pressed", self, "toggle_vsync")
	assert(err == OK)
	err = _fullscreen.connect("pressed", self, "toggle_fullscreen")
	assert(err == OK)
	err = _debug.connect("pressed", self, "toggle_debug")
	assert(err == OK)
	err = _controls.connect("pressed", get_parent().get_node('InputMapper'), "activate")
	assert(err == OK)
	
	_vsync.pressed = Settings.fetch("vsync", true)
	_fullscreen.pressed = Settings.fetch("fullscreen", false)
	_debug.pressed = Settings.fetch("debug", false)
	
	err = _mouse_sensitivity.connect("value_changed", self, "update_mouse_sensitivity")
	assert(err == OK)
	err = _joypad_sensitivity.connect("value_changed", self, "update_joypad_sensitivity")
	assert(err == OK)
	err = _field_of_view.connect("value_changed", self, "update_field_of_view")
	assert(err == OK)
	
	err = $Button_Back.connect("pressed", self, "hide")
	assert(err == OK)
	
	load_settings()

func activate():
	show()
	Game.focus_first_control(self)

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
	Console.log("MOUSE SENSITIVITY = " + str(value))
	Settings.store("mouse_sensitivity", value)
	load_settings()

func update_joypad_sensitivity(value):
	Settings.store("joypad_sensitivity", value)
	load_settings()

func update_field_of_view(value):
	Settings.store("field_of_view", value)
	load_settings()

func load_settings():
	Debug.enabled = _debug.pressed
	OS.window_fullscreen = _fullscreen.pressed
	OS.vsync_enabled = _vsync.pressed
	_mouse_sensitivity.value = Game.get_mouse_sensitivity(true)
	_joypad_sensitivity.value = Game.get_joypad_sensitivity(true)
	_field_of_view.value = Game.get_field_of_view(true)
