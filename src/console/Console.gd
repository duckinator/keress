extends Control

var scrollback
var input

func _ready():
	scrollback = $Panel/Scrollback
	scrollback.clear()
	input = $Panel/Input
	input.connect("text_changed", self, "_text_changed")
	input.connect("text_entered", self, "run")

func _text_changed(new_text):
	if "`" in new_text:
		input.text = new_text.replace("`", "")
		Console.hide()

func log_line(line):
	scrollback.append_bbcode(line.strip_edges(false, true))
	scrollback.newline()

func clear():
	scrollback.clear()

func set_enabled(enabled):
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		visible = true
		input.call_deferred("grab_focus")
		input.call_deferred("set_cursor_position", len(input.text))
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		visible = false
		input.release_focus()

func run(line):
	if line == "":
		return
	input.text = ""
	$CommandProcessor.run(line)
