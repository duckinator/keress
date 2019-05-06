extends Node

const MAIN_MENU_PATH = "res://menus/MainMenu.tscn"
const DEBUG_SCENE = preload("res://overlays/Debug_Display.tscn")
const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")
var popup = null

var canvas_layer
var debug_display = null

var reload_level = false
var playing = false

var current_level

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	current_level = Settings.fetch("current_level", 1)

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
	vbox.get_node("Resume_Button").connect("pressed", self, "resume")
	vbox.get_node("Reload_Button").connect("pressed", self, "restart_level")
	vbox.get_node("Menu_Button").connect("pressed", self, "main_menu")
	vbox.get_node("Quit_Button").connect("pressed", self, "quit")
	popup.connect("popup_hide", self, "popup_resume")
	canvas_layer.add_child(popup)
	focus_first_control(vbox)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS

func resume():
	get_tree().paused = false
	if popup != null:
		popup.queue_free()
		popup = null

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

func load_level(level):
	Game.playing = true
	var err = load_scene(get_level_scene(level))
	if err:
		Console.error("load_level(): Could not load level " + str(level) + ". (Error " + str(err) + ".)")

func previous_level():
	current_level -= 1
	Settings.store("current_level", current_level)
	var err = load_level(current_level)
	if err:
		Console.error("Couldn't load previous level (" + str(current_level) + ").")
		Console.error(err)

func next_level():
	current_level += 1
	Settings.store("current_level", current_level)
	var err = load_level(current_level)
	if err:
		Console.error("Couldn't load next level (" + str(current_level) + ").")
		Console.error(err)

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

func spawn_player(scene):
	var spawn = find_spawn_point(scene)
	var player = scene.get_node('Player')
	player.translation = spawn.translation
	player.rotation = spawn.rotation

func focus_first_control(node):
	for child in node.get_children():
		# TODO: Make this more robust.
		if child.has_method("grab_focus") and not child is Label and not child is HSeparator:
			child.grab_focus()
			break

func get_total_gravity_for(body):
	var state = PhysicsServer.body_get_direct_state(body.get_rid())
	return state.get_total_gravity()

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_F4:
		previous_level()

	if event is InputEventKey and event.pressed and event.scancode == KEY_F5:
		restart_level()

	if event is InputEventKey and event.pressed and event.scancode == KEY_F6:
		next_level()