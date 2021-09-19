extends Node

signal load_map

const MAPS = {
	"Cube": "res://blender/maps/cube/Cube.escn",
}

const BLENDER_MAP_SCENE = "res://blender_map/BlenderMap.tscn"
const MAIN_MENU_SCENE = "res://menus/MainMenu.tscn"

var map = null

func setup(parent_scene):
	var scene = load(MAPS[map]).instance()
	parent_scene.add_child(scene)
	Entities.spawn_for_map(map)

func load_scene(new_scene_path):
	return get_tree().change_scene(new_scene_path)

func load_map(new_map=null):
	if new_map == null:
		map = MAPS.keys()[0]
	else:
		map = new_map
	Game.playing = true
	var err = load_scene(BLENDER_MAP_SCENE)
	if err:
		Console.error("load_map(): Could not load map " + map + ". (Error " + str(err) + ".)")
	emit_signal("load_map", map)
	
	# If Game.resume() isn't deferred, it gets called before the map is loaded.
	Game.call_deferred("resume")

func main_menu():
	load_scene(MAIN_MENU_SCENE)

func in_game():
	return (get_tree().current_scene.name == "BlenderLevel")
