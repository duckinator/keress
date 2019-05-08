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

func _process(delta):
	update_buttons()

func add_input_mapper(parent, setting, display_name):
	var hbox = HBoxContainer.new()
	var hbox2 = HBoxContainer.new()
	var vbox = VBoxContainer.new()
	var label = Label.new()
	var button = Button.new()
	var list = Label.new()
	label.text = display_name
	button.text = "..." # TODO: Is there a better way to convey that it's not set?
	button.connect("pressed", self, "prompt_input_map", [button, setting])
	button.name = "Button"
	list.name = "ActionList"
	hbox.name = "HBox"
	hbox2.name = "HBox2"
	vbox.set_meta("action", setting)
	
	hbox.add_child(label)
	hbox.add_child(button)
	vbox.add_child(hbox)
	var bullshit = Label.new()
	bullshit.text = "    "
	hbox2.add_child(bullshit)
	hbox2.add_child(list)
	vbox.add_child(hbox2)
	parent.add_child(vbox)

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
	print("UPDATE INPUT MAP: button=" + str(button) + "; setting=" + setting)

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
	print("CONFIRMED")
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

func update_buttons():
	for vbox in controls.get_children():
		if not vbox is VBoxContainer:
			continue
		
		var hbox = vbox.get_node("HBox")
		var action = vbox.get_meta("action")
		var label = vbox.get_node("HBox2").get_node("ActionList")
		var action_list = InputMap.get_action_list(action)
		var action_list_str = ""
		for idx in range(0, len(action_list)):
			if idx != 0:
				action_list_str += "\n"
			action_list_str += action_list[idx].as_text()
		label.text = action_list_str

func reset():
	InputMap.load_from_globals()