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
	$Button_Back.grab_focus()

func deactivate():
	hide()
	# A bit kludgy, but eh.
	if get_parent().name == "Panels":
		get_parent().get_parent().activate()
	else:
		get_parent().activate()

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

func update_field_of_view(value):
	Settings.store("field_of_view", value)
	load_settings()

func load_settings():
	_mouse_sensitivity.value = Settings.fetch("mouse_sensitivity")
	_joypad_sensitivity.value = Settings.fetch("joypad_sensitivity")
	_field_of_view.value = Settings.fetch("field_of_view")
	
	_vsync.pressed = Settings.fetch("vsync")
	_fullscreen.pressed = Settings.fetch("fullscreen")
	_debug.pressed = Settings.fetch("debug")
	
	Debug.enabled = _debug.pressed
	OS.window_fullscreen = _fullscreen.pressed
	OS.vsync_enabled = _vsync.pressed
