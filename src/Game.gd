extends Node

const MAIN_MENU_PATH = "res://menus/Main_Menu.tscn"
const DEBUG_SCENE = preload("res://overlays/Debug_Display.tscn")
const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")
var popup = null
var closing_popup= false

var canvas_layer
var debug_display = null

var reload_level = false
var playing = false

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func _process(_delta):
	if not playing:
		close_popup()
		return
	
	if closing_popup:
		closing_popup = false
		return

	if not Input.is_action_just_pressed("ui_cancel"):
		return
	
	if popup != null:
		return

	popup = PAUSE_SCENE.instance()

	popup.get_node("Resume_Button").connect("pressed", self, "popup_resume")
	popup.get_node("Reload_Button").connect("pressed", self, "popup_reload")
	popup.get_node("Menu_Button").connect("pressed", self, "popup_menu")
	popup.get_node("Quit_Button").connect("pressed", self, "popup_quit")
	popup.connect("popup_hide", self, "popup_resume")

	canvas_layer.add_child(popup)
	popup.popup_centered()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS

func popup_resume():
	close_popup()

func popup_reload():
	close_popup()
	reload_level = true

func popup_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	close_popup()
	load_new_scene(MAIN_MENU_PATH)

func popup_quit():
	quit()

func close_popup():
	get_tree().paused = false

	if popup != null:
		popup.queue_free()
		popup = null
		closing_popup = true

func add_debug_display():
	if debug_display == null:
		debug_display = DEBUG_SCENE.instance()
		canvas_layer.add_child(debug_display)

func remove_debug_display():
	if debug_display:
		debug_display.queue_free()
		debug_display = null

func load_new_scene(new_scene_path):
	# Reset respawn points before loading a level.
	#respawn_points = null

	# Clear previously-used sounds.
	#for sound in created_audio:
	#	if sound:
	#		sound.queue_free()
	#created_audio.clear()
	
	return get_tree().change_scene(new_scene_path)

func spawn_scene(asset, pos):
	var scene = load("res://" + asset + ".tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name(asset)
	get_parent().call_deferred("add_child", scene_instance)
	scene_instance.set_translation(pos)
	return scene_instance

func quit():
	get_tree().quit()

func get_total_gravity_for(body):
	var state = PhysicsServer.body_get_direct_state(body.get_rid())
	return state.get_total_gravity()