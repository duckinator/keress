extends VBoxContainer

export var action = ""
export var label = "" setget set_label, get_label

onready var _label = $HBoxContainer/Label
onready var button = $HBoxContainer/Button
onready var list = $HBoxContainer2/ActionList

func _ready():
	pass # Replace with function body.

func _process(delta):
	if action == "" or action == null:
		return
	
	var action_list = InputMap.get_action_list(action)
	var action_list_str = ""
	for idx in range(0, len(action_list)):
		if idx != 0:
			action_list_str += "\n"
		action_list_str += action_list[idx].as_text()
	list.text = action_list_str

func set_label(text):
	_label.text = text

func get_label():
	return label.text

func set_prompt_function(obj, method):
	button.connect("pressed", obj, method, [button, action])
