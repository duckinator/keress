extends Node

signal resume

const DEFAULT_MOUSE_SENSITIVITY = 20
const DEFAULT_JOYPAD_SENSITIVITY = 20
const DEFAULT_FIELD_OF_VIEW = 90

const MAIN_MENU_PATH = "res://menus/MainMenu.tscn"
const DEBUG_SCENE = preload("res://overlays/DebugOverlay.tscn")
const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")
var popup = null

var canvas_layer
var debug_display = null
var mob_debug_display = null

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
	# If we're not playing and the pause popup is visible, hide the pause menu.
	if not playing and popup != null:
		_hide_pause_menu()
		return

	if Input.is_action_just_pressed("ui_cancel"):
		if popup == null:
			pause()
		else:
			resume()

func pause():
	popup = PAUSE_SCENE.instance()
	var vbox = popup.get_node("CenterContainer/VBoxContainer")
	var settings = popup.get_node("Settings")
	vbox.get_node("Resume_Button").connect("pressed", self, "resume")
	vbox.get_node("Settings_Button").connect("pressed", self, "show_settings", [settings])
	vbox.get_node("Menu_Button").connect("pressed", self, "main_menu")
	vbox.get_node("Quit_Button").connect("pressed", self, "quit")
	canvas_layer.add_child(popup)
	vbox.get_node("Resume_Button").grab_focus()
	show_cursor()
	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS

func _hide_pause_menu():
	if playing:
		capture_cursor()
	get_tree().paused = false
	if popup != null:
		popup.queue_free()
		popup = null

func resume():
	_hide_pause_menu()
	emit_signal("resume")

func show_settings(settings):
	settings.activate()

func main_menu():
	_hide_pause_menu()
	MapManager.load_scene(MAIN_MENU_PATH)

func quit():
	get_tree().quit()

func add_debug_display():
	if debug_display == null:
		debug_display = DEBUG_SCENE.instance()
		canvas_layer.add_child(debug_display)

func remove_debug_display():
	if debug_display:
		debug_display.queue_free()
		debug_display = null

func spawn_scene(asset, pos=null, rot=null):
	var scene = load("res://" + asset + ".tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name(asset)
	get_parent().call_deferred("add_child", scene_instance)
	if pos != null:
		scene_instance.translation = pos
	if rot != null:
		scene_instance.rotation = rot
	return scene_instance

func find_spawn_point(scene):
	var spawns = []
	if scene.has_node("Spawns"):
		for node in scene.get_node("Spawns").get_children():
			spawns.push_back(node)
	else:
		Console.error("Couldn't find a spawn point!")
	return spawns[rand_range(0, len(spawns))]

func get_player(scene=null):
	if scene == null:
		scene = get_tree().current_scene
	
	if scene.has_node('Player'):
		return scene.get_node('Player')
	else:
		return null

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

func get_total_gravity_for(body):
	var state = PhysicsServer.body_get_direct_state(body.get_rid())
	return state.get_total_gravity()

func setup_hbox_vbox(hbox, vbox):
	hbox.add_spacer(true)
	hbox.add_spacer(false)
	hbox.add_constant_override("separation", 20)
	vbox.add_constant_override("separation", 20)
