extends Node

var mobs : get = get_mobs

var ENTITIES = {
	"Player": preload("res://player/Player.tscn"),
	#"Enemy1": preload("res://enemies/enemy1/Enemy1.tscn"),
}

var ENTITIES_FOR_MAP = {
	"Cube": {
		"Player": [Vector3(0, 2, 0)],
		#"Enemy1": [
		#	Vector3(15, 3, -14),
		#	Vector3(10, 3, -12),
		#	Vector3(0, 3, -10),
		#	Vector3(0, 3, -12),
		#	Vector3(-10, 3, -12),
		#	Vector3(-15, 3, -14),
		#]
	},
}

func get_mobs():
	return get_tree().get_nodes_in_group("mobs")

func spawn_for_map(map):
	Console.log("Spawning entities for map: " + map)
	
	for enemy_type in ENTITIES_FOR_MAP[map]:
		for pos in ENTITIES_FOR_MAP[map][enemy_type]:
			Console.log("    %s at %s." % [enemy_type, pos])
			spawn(enemy_type, pos)

func spawn(entity_name, pos):
	var scene = ENTITIES[entity_name].instantiate()
	scene.translate(pos)
	get_tree().current_scene.add_child(scene)
