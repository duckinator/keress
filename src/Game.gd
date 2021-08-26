extends Node

signal load_level

const DEFAULT_MOUSE_SENSITIVITY = 20
const DEFAULT_JOYPAD_SENSITIVITY = 20
const DEFAULT_FIELD_OF_VIEW = 90

# TODO: See if these can be automagically determined?
const FIRST_LEVEL = 1
const MIN_LEVEL = FIRST_LEVEL
const MAX_LEVEL = 3

const MAIN_MENU_PATH = "res://menus/MainMenu.tscn"
const DEBUG_SCENE = preload("res://overlays/Debug_Display.tscn")
const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")
var popup = null

var canvas_layer
var debug_display = null

var reload_level = false
var playing = false

var _cache = {}

func set_current_level(level):
	return Settings.store("current_level", level)

func get_current_level():
	return Settings.fetch("current_level", 1)

func get_mouse_sensitivity(cache_bust=false):
	if cache_bust or not "mouse_sensitivity" in _cache.keys():
		_cache["mouse_sensitivity"] = Settings.fetch("mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)
	return _cache["mouse_sensitivity"]

func get_joypad_sensitivity(cache_bust=false):
	if cache_bust or not "joypad_sensitivity" in _cache.keys():
		_cache["joypad_sensitivity"] = Settings.fetch("joypad_sensitivity", DEFAULT_JOYPAD_SENSITIVITY)
	return _cache["joypad_sensitivity"]

func get_field_of_view(cache_bust=false):
	if cache_bust or not "field_of_view" in _cache.keys():
		_cache["field_of_view"] = Settings.fetch("field_of_view", DEFAULT_FIELD_OF_VIEW)
	return _cache["field_of_view"]

func show_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func _process(_delta):
	# If we're not playing, hide the pause menu.
	if not playing:
		resume()
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
	vbox.get_node("Reload_Button").connect("pressed", self, "restart_level")
	vbox.get_node("Menu_Button").connect("pressed", self, "main_menu")
	vbox.get_node("Quit_Button").connect("pressed", self, "quit")
	canvas_layer.add_child(popup)
	focus_first_control(vbox)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS

func resume():
	if playing:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	if popup != null:
		popup.queue_free()
		popup = null

func show_settings(settings):
	settings.activate()

func restart_level():
	resume()
	reload_level = true

func main_menu():
	resume()
	load_scene(MAIN_MENU_PATH)

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

func get_level_scene(level):
	return "res://levels/Level_" + str(level).pad_zeros(3) + ".tscn"

func load_scene(new_scene_path):
	# Reset respawn points before loading a level.
	#respawn_points = null

	# Clear previously-used sounds.
	#for sound in created_audio:
	#	if sound:
	#		sound.queue_free()
	#created_audio.clear()
	
	return get_tree().change_scene(new_scene_path)

func load_level(level, should_spawn_player=false):
	emit_signal("load_level", level)
	Game.playing = true
	var err = load_scene(get_level_scene(level))
	if err:
		Console.error("load_level(): Could not load level " + str(level) + ". (Error " + str(err) + ".)")
	set_current_level(level)
	if should_spawn_player:
		call_deferred("spawn_player")

func previous_level():
	var prev_level = get_current_level() - 1
	
	if prev_level < MIN_LEVEL:
		Console.error("Can't go to previous level; current_level is " + str(get_current_level()) + ", MIN_LEVEL is " + str(MIN_LEVEL))
		return

	
	var err = load_level(prev_level)
	if err:
		Console.error("Couldn't load previous level (" + str(prev_level) + ").")
		Console.error(err)
		return

func next_level(seamless_transition=false):
	var _next_level = get_current_level() + 1
	
	if _next_level > MAX_LEVEL:
		Console.error("Can't go to next level; current_level is " + str(get_current_level()) + ", MAX_LEVEL is " + str(MAX_LEVEL))
		return
	
	if seamless_transition:
		Game.store_player_rotation()
	
	var err = load_level(_next_level)
	if err:
		Console.error("Couldn't load next level (" + str(_next_level) + ").")
		Console.error(err)
		return

	if seamless_transition:
		call_deferred("restore_player_rotation")

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

func spawn_player(scene=null):
	if scene == null:
		scene = get_tree().current_scene
	var spawn = find_spawn_point(scene)
	var player = get_player(scene)
	player.translation = spawn.translation
	player.rotation = spawn.rotation

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

var stored_player_rotation = null
func store_player_rotation():
	var player = get_player()
	if player == null:
		Console.error("Game.gd/store_player_rotation(): player is null")
		return
	var rot1 = player.rotation_degrees
	var rot2 = player.rotation_helper.rotation_degrees
	stored_player_rotation = [rot1, rot2]
	Console.log("store...(): player=" + str(player) + "; stored_player_rotation = " + str(stored_player_rotation))

func restore_player_rotation():
	var player = get_player()
	if player == null:
		Console.error("Game.gd/restore_player_rotation(): player is null")
		return
	Console.log("restore...(): player=" + str(player) + "; stored_player_rotation = " + str(stored_player_rotation))
	if stored_player_rotation == null:
		return
	player.rotation_degrees = stored_player_rotation[0]
	player.rotation_helper.rotation_degrees = stored_player_rotation[1]
	stored_player_rotation = null

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_F4:
		previous_level()

	if event is InputEventKey and event.pressed and event.scancode == KEY_F5:
		restart_level()

	if event is InputEventKey and event.pressed and event.scancode == KEY_F6:
		next_level()

func setup_hbox_vbox(hbox, vbox):
	hbox.add_spacer(true)
	hbox.add_spacer(false)
	hbox.add_constant_override("separation", 20)
	vbox.add_constant_override("separation", 20)
