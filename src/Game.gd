extends Node

signal resume

const MAIN_MENU_PATH = "res://menus/MainMenu.tscn"
const DEBUG_SCENE = preload("res://overlays/DebugOverlay.tscn")
const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")

var canvas_layer
var debug_display = null

var playing = false

func show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func _process(_delta):
	if playing and Input.is_action_just_pressed("ui_cancel"):
		pause()

func pause():
	canvas_layer.add_child(PAUSE_SCENE.instance())

func resume():
	capture_cursor()
	emit_signal("resume")

func main_menu():
	MapManager.load_scene(MAIN_MENU_PATH)

func quit():
	get_tree().quit()

func add_debug_display():
	if debug_display == null:
		debug_display = DEBUG_SCENE.instance()
		canvas_layer.add_child(debug_display)

func focus_first_control(node):
	for child in node.get_children():
		# Skip hidden nodes.
		if not child is Node and not child.visible:
			continue
		
		# If it shouldn't be auto-focused, don't auto-focus it.
		if child.has_meta("no_auto_focus"):
			continue
		
		# If it's a "Done" button, used for going back up to the previous menu,
		# don't auto-focus it.
		if child.name == "Done":
			continue
		
		# These are the only types of things we want to auto-focus.
		if not (child is Button or child is HSlider or child is VSlider):
			continue
		
		if child.has_method("grab_focus"):
			child.grab_focus()
			return true
	
	# If we get here, we've not found something - go deeper.
	for child in node.get_children():
		if focus_first_control(child):
			return true
	return false

func setup_hbox_vbox(hbox, vbox):
	hbox.add_spacer(true)
	hbox.add_spacer(false)
	hbox.add_constant_override("separation", 20)
	vbox.add_constant_override("separation", 20)
