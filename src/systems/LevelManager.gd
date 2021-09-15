extends Node

signal load_level

const MAPS = [
	null,
	"res://blender/exports/Warehouse.escn",
]

const BLENDER_LEVEL_SCENE = "res://blender_level/BlenderLevel.tscn"

# TODO: See if these can be automagically determined?
const FIRST_LEVEL = 1
const MIN_LEVEL = FIRST_LEVEL
const MAX_LEVEL = 3

var level_cleared = false

func _ready():
	Game.connect("load_level", self, "reset")

func setup(parent_scene):
	var map = load(MAPS[get_current_level()]).instance()
	parent_scene.add_child(map)
	Entities.spawn_for_level(get_current_level())

func reset(_level):
	level_cleared = false

func _process(delta):
	if Game.playing and not level_cleared and len(Entities.mobs) == 0:
		level_cleared = true
		Console.log("woo!")

func set_current_level(level):
	return Settings.store("current_level", level)

func get_current_level():
	return Settings.fetch("current_level")

func restart_level():
	load_level(get_current_level())
	Game.resume()

func get_level_scene(level):
	return "res://levels/Level_" + str(level).pad_zeros(3) + ".tscn"

func load_scene(new_scene_path):
	return get_tree().change_scene(new_scene_path)

func load_level(level):
	emit_signal("load_level", level)
	Game.playing = true
	var err = load_scene(BLENDER_LEVEL_SCENE)
	if err:
		Console.error("load_level(): Could not load level " + str(level) + ". (Error " + str(err) + ".)")
	set_current_level(level)

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

func next_level():
	var _next_level = get_current_level() + 1
	
	if _next_level > MAX_LEVEL:
		Console.error("Can't go to next level; current_level is " + str(get_current_level()) + ", MAX_LEVEL is " + str(MAX_LEVEL))
		return
	
	var err = load_level(_next_level)
	if err:
		Console.error("Couldn't load next level (" + str(_next_level) + ").")
		Console.error(err)
		return
