extends Control

const CONFIG_FILE = "user://InputMapper.cfg"
const CONFIG_SECTION = "InputMapper"

var _waiting_for_input

const CONTROLS = {
	#"ui_accept": "Accept",
	#"ui_select": "Select",
	"ui_cancel": "Pause/Resume",
	#"ui_left": "Left (Menu)",
	#"ui_right": "Right (Menu)",
	#"ui_up": "Up (Menu)",
	#"ui_down": "Down (Menu)",
	
	"movement_forward": "Move Forward",
	"movement_backward": "Move Backward",
	"movement_left": "Move Left",
	"movement_right": "Move Right",
	#"movement_sprint": "Sprint",
	"movement_jump": "Jump",
	#"movement_crouch": "Crouch",

	"action_primary": "Primary action/fire weapon",
	"action_secondary": "Secondary action",
	"action_reload": "Reload",
	#"action_quick_switch": "Quick switch",
}

const JOYPAD_CONTROLS = {
	"look_left": "Turn left",
	"look_right": "Turn right",
	"look_up": "Look up",
	"look_down:": "Look down",
}

@onready var done = $Panel/ScrollContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Done
@onready var hbox = $Panel/ScrollContainer/HBoxContainer
@onready var vbox = hbox.get_node("VBoxContainer")
#onready var sound = vbox.get_node("Sound")
@onready var controls = vbox.get_node("Controls")
@onready var mouse = vbox.get_node("Mouse")
@onready var joypad = vbox.get_node("Joypad")
	
@onready var hbox2 = vbox.get_node("HBoxContainer2")
@onready var controls_reset = hbox2.get_node("Controls_Reset")
@onready var hbox3 = vbox.get_node("HBoxContainer3")
@onready var controls_save = hbox3.get_node("Controls_Save")

func _ready():
	var err = controls_reset.pressed.connect(Callable(self, "reset_config"))
	Console.error_unless_ok("controls_reset.pressed.connect() failed", err)
	err = controls_save.pressed.connect(Callable(self, "save_config"))
	Console.error_unless_ok("controls_save.pressed.connect() failed", err)
	err = done.pressed.connect(Callable(self, "deactivate"))
	Console.error_unless_ok("done.pressed.connect() failed", err)
	
	for setting in CONTROLS.keys():
		add_input_mapper(controls, setting, CONTROLS[setting])
	
	for setting in JOYPAD_CONTROLS.keys():
		add_input_mapper(joypad, setting, JOYPAD_CONTROLS[setting])
	
	load_config()

func activate():
	show()
	done.grab_focus()

func deactivate():
	hide()
	get_parent().get_parent().activate()

func add_input_mapper(parent, setting, display_name):
	var scene = load("res://menus/ActionMapper.tscn").instantiate()
	parent.add_child(scene)
	scene.label = display_name
	scene.action = setting
	scene.set_prompt_function(self, "prompt_input_map")

func prompt_input_map(button, setting):
	var err
	var dialog = $InputMapDialog
	var cancel = dialog.get_cancel_button()
	
	_waiting_for_input = true
	dialog.popup_centered()
	dialog.exclusive = true
	dialog.release_focus()
	dialog.disconnect("confirmed", Callable(self, "prompt_confirm"))
	err = dialog.connect("confirmed", Callable(self, "prompt_confirm").bind(button, setting))
	Console.error_unless_ok("dialog.connect('confirmed') failed", err)
	err = cancel.connect("pressed", Callable(self, "prompt_hide"))
	Console.error_unless_ok("cancel.connect('pressed') failed", err)

var last_event = null
func _input(event):
	if not _waiting_for_input:
		return
		
	if event is InputEventMouseMotion:
		return
	
	print(str(event))
	if Input.is_key_pressed(KEY_ESCAPE):
		prompt_hide()
	elif not event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		last_event = event
		$InputMapDialog.get_ok_button().emit_signal("pressed")
		prompt_hide()

func prompt_confirm(_button, action):
	if last_event != null:
		var event = last_event
		if InputMap.action_has_event(action, event):
			InputMap.action_erase_event(action, event)
		else:
			InputMap.action_add_event(action, event)
	_waiting_for_input = false

func prompt_hide():
	_waiting_for_input = false
	$InputMapDialog.hide()

func reset_config():
	InputMap.load_from_project_settings()
	save_config()

func load_config():
	if not FileAccess.file_exists(CONFIG_FILE):
		return
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	Console.error_unless_ok("InputMapper.gd: load_config(): Error loading " + CONFIG_FILE, err)
	
	if not config.has_section(CONFIG_SECTION):
		Console.error("InputMapper.gd: load_config(): Config file " + CONFIG_FILE + " does not have section " + CONFIG_SECTION)
		return
	
	for action in config.get_section_keys(CONFIG_SECTION):
		var action_events = config.get_value(CONFIG_SECTION, action)
		
		for event in action_events:
			if event in InputMap.action_get_events(action):
				continue
			
			InputMap.action_add_event(action, event)

func save_config():
	var config = ConfigFile.new()
	
	for action in CONTROLS.keys():
		config.set_value(CONFIG_SECTION, action, InputMap.action_get_events(action))
	
	var err = config.save(CONFIG_FILE)
	Console.error_unless_ok("InputMapper.gd: save_config(): Error saving " + CONFIG_FILE, err)
	return err
