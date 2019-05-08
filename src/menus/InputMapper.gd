extends Control

const CONFIG_FILE = "user://InputMapper.cfg"
const CONFIG_SECTION = "InputMapper"

var _waiting_for_input

const CONTROLS = {
	#"ui_accept": "Accept",
	#"ui_select": "Select",
	#"ui_cancel": "Cancel",
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

var controls
var sound
var mouse
var joypad
var done

onready var categories = {
	#"sound": sound,
	"controls": controls,
	"mouse": mouse,
	"joypad": joypad
}

func label(text):
	var l = Label.new()
	l.text = text
	return l

func _ready():
	done = $Panel/Done
	var hbox = $Panel/ScrollContainer/HBoxContainer
	var vbox = hbox.get_node("VBoxContainer")
	#sound = vbox.get_node("Sound")
	controls = vbox.get_node("Controls")
	mouse = vbox.get_node("Mouse")
	joypad = vbox.get_node("Joypad")
	
	var hbox2 = vbox.get_node("HBoxContainer2")
	var controls_reset = hbox2.get_node("Controls_Reset")
	var controls_save = hbox2.get_node("Controls_Save")
	
	Game.show_cursor()
	hbox.add_spacer(true)
	hbox.add_spacer(false)
	hbox.add_constant_override("separation", 20)
	vbox.add_constant_override("separation", 20)
	
	controls_reset.connect("pressed", self, "reset_config")
	controls_save.connect("pressed", self, "save_config")
	
	for setting in CONTROLS.keys():
		add_input_mapper(controls, setting, CONTROLS[setting])

	load_config()


func add_input_mapper(parent, setting, display_name):
	var scene = load("res://menus/ActionMapper.tscn").instance()
	parent.add_child(scene)
	scene.label = display_name
	scene.action = setting
	scene.set_prompt_function(self, "prompt_input_map")

func prompt_input_map(button, setting):
	var dialog = $InputMapDialog
	var okay = dialog.get_ok()
	var cancel = dialog.get_cancel()
	
	_waiting_for_input = true
	dialog.popup_centered()
	dialog.popup_exclusive = true
	dialog.release_focus()
	dialog.disconnect("confirmed", self, "prompt_confirm")
	dialog.connect("confirmed", self, "prompt_confirm", [button, setting])
	cancel.connect("pressed", self, "prompt_hide")

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
		get_tree().set_input_as_handled()
		last_event = event
		$InputMapDialog.get_ok().emit_signal("pressed")
		prompt_hide()

func prompt_confirm(button, action):
	if last_event != null:
		var event = last_event
		if InputMap.action_has_event(action, event):
			InputMap.action_erase_event(action, event)
			return
		
		for act in CONTROLS:
			if InputMap.action_has_event(act, event):
				InputMap.action_erase_event(act, event)
		InputMap.action_add_event(action, event)
	_waiting_for_input = false

func prompt_hide():
	_waiting_for_input = false
	$InputMapDialog.hide()

func reset_config():
	InputMap.load_from_globals()

func load_config():
	if not File.new().file_exists(CONFIG_FILE):
		return
	
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err != OK:
		Console.error("InputMapper.gd: load_config(): Error loading " + CONFIG_FILE + ". (" + str(err) + ")")
		return
	
	if not config.has_section(CONFIG_SECTION):
		Console.error("InputMapper.gd: load_config(): Config file " + CONFIG_FILE + " does not have section " + CONFIG_SECTION)
		return
	
	for action in config.get_section_keys(CONFIG_SECTION):
		var action_events = config.get_value(CONFIG_SECTION, action)
		
		for event in action_events:
			if event in InputMap.get_action_list(action):
				continue
			
			InputMap.action_add_event(action, event)

func save_config():
	var config = ConfigFile.new()
	
	for action in CONTROLS.keys():
		config.set_value(CONFIG_SECTION, action, InputMap.get_action_list(action))
	
	var err = config.save(CONFIG_FILE)
	if err != OK:
		Console.error("InputMapper.gd: save_config(): Error saving " + CONFIG_FILE + ". (" + str(err) + ")")
	return err