extends ColorRect

@onready var vbox = $ScrollContainer/HBoxContainer/VBoxContainer
@onready var _vsync = vbox.get_node('CheckButton_VSync')
@onready var _fullscreen = vbox.get_node('CheckButton_Fullscreen')
@onready var _gun_on_left = vbox.get_node("CheckButton_GunOnLeft")
@onready var _debug = vbox.get_node('CheckButton_Debug')
@onready var _controls = vbox.get_node('Button_Controls')
@onready var _mouse_sensitivity = vbox.get_node('HSlider_Mouse_Sensitivity')
@onready var _joypad_sensitivity = vbox.get_node('HSlider_Joypad_Sensitivity')
@onready var _field_of_view = vbox.get_node('HSlider_Field_of_View')

func _ready():
	var err
	
	err = _vsync.pressed.connect(Callable(self, "toggle_vsync"))
	Console.error_unless_ok("_vsync.pressed.connect() failed", err)
	err = _fullscreen.pressed.connect(Callable(self, "toggle_fullscreen"))
	Console.error_unless_ok("_fullscreen.pressed.connect() failed", err)
	err = _gun_on_left.pressed.connect(Callable(self, "toggle_gun_on_left"))
	Console.error_unless_ok("_gun_on_left.pressed.connect() failed", err)
	err = _debug.pressed.connect(Callable(self, "toggle_debug"))
	Console.error_unless_ok("_debug.pressed.connect() failed", err)
	
	err = _mouse_sensitivity.connect("value_changed", Callable(self, "update_mouse_sensitivity"))
	Console.error_unless_ok("_mouse_sensitivity.connect('value_changed') failed", err)
	err = _joypad_sensitivity.connect("value_changed", Callable(self, "update_joypad_sensitivity"))
	Console.error_unless_ok("_joypad_sensitivity.connect('value_changed') failed", err)
	err = _field_of_view.connect("value_changed", Callable(self, "update_field_of_view"))
	Console.error_unless_ok("_field_of_view.connect('value_changed') failed", err)
	
	err = $Button_Back.pressed.connect(Callable(self, "deactivate"))
	Console.error_unless_ok("$Button_Back.pressed.connect() failed", err)
	
	load_settings()

func activate():
	show()
	$Button_Back.grab_focus()

func deactivate():
	hide()
	get_parent().get_parent().activate()

func toggle_vsync():
	Settings.store("vsync", _vsync.button_pressed)
	load_settings()

func toggle_fullscreen():
	Settings.store("fullscreen", _fullscreen.button_pressed)
	load_settings()

func toggle_gun_on_left():
	Settings.store("gun_on_left", _gun_on_left.button_pressed)
	load_settings()

func toggle_debug():
	Settings.store("debug", _debug.button_pressed)
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
	
	_vsync.button_pressed = Settings.fetch("vsync")
	_fullscreen.button_pressed = Settings.fetch("fullscreen")
	_gun_on_left.button_pressed = Settings.fetch("gun_on_left")
	_debug.button_pressed = Settings.fetch("debug")
	
	Debug.enabled = _debug.pressed
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (_fullscreen.button_pressed) else Window.MODE_WINDOWED
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (_vsync.button_pressed) else DisplayServer.VSYNC_DISABLED)
