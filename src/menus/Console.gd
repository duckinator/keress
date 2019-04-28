extends Control

var canvas_layer

var scrollback
var input

func _ready():
	scrollback = $Panel/Scrollback
	scrollback.clear()
	input = $Panel/Input
	input.connect("text_changed", self, "_text_changed")

func log(text):
	var lines = text.split("\n")
	for line in lines:
		scrollback.append_bbcode(line)
		scrollback.newline()

func set_enabled(enabled):
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		visible = true
		input.call_deferred("grab_focus")
	else:
		visible = false
		input.release_focus()

func _text_changed():
	var text = input.text
	if "\n" in text:
		_run(text.strip_edges())
		input.text = ""
		
func _run(line):
	if line == "":
		return
	$CommandProcessor.run(line)