extends Node

signal loading_map
signal load_main_menu

const MAPS = [
	"Cube",
]

const BLENDER_MAP_SCENE = "res://blender_map/BlenderMap.tscn"
const MAIN_MENU_SCENE = "res://menus/MainMenu.tscn"

var map = null

func setup(parent_scene):
	var map_path = _map_to_path(map)
	var scene = load(map_path)
	if scene == null:
		Console.error("Failed to load map %s: `load(%s)` returned null" % [var_to_str(map), var_to_str(map_path)])
		return
	var instance = scene.instantiate()
	parent_scene.add_child(instance)
	Entities.spawn_for_map(map)

func load_scene(new_scene_path):
	return get_tree().change_scene_to_file(new_scene_path)

func load_map(new_map=null):
	if new_map == null:
		map = MAPS[0]
	else:
		map = new_map
	var err = load_scene(BLENDER_MAP_SCENE)
	Console.error_unless_ok("load_map(): Could not load map " + map, err)
	loading_map.emit(map)
	
	# If Game.resume() isn't deferred, it gets called before the map is loaded.
	Game.call_deferred("resume")

func main_menu():
	load_scene(MAIN_MENU_SCENE)
	load_main_menu.emit()

func _map_to_path(map_name):
	return "res://blender/maps/%s/%s.escn" % [map_name, map_name]
