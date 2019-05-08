extends Control

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

onready var hbox = $Panel/ScrollContainer/HBoxContainer
onready var vbox = hbox.get_node("VBoxContainer")
#onready var sound = vbox.get_node("Sound")
onready var controls = vbox.get_node("Controls")
onready var mouse = vbox.get_node("Mouse")
onready var joypad = vbox.get_node("Joypad")

onready var controls_reset = vbox.get_node("HBoxContainer2").get_node("Controls_Reset")

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
	Game.show_cursor()
	hbox.add_spacer(true)
	hbox.add_spacer(false)
	hbox.add_constant_override("separation", 20)
	vbox.add_constant_override("separation", 20)
	
	controls_reset.connect("pressed", self, "reset")
	
	for setting in CONTROLS.keys():
		add_input_mapper(controls, setting, CONTROLS[setting])

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

func reset():
	InputMap.load_from_globals()