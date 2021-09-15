extends Node

var mobs setget , get_mobs

var ENTITIES = {
	"Player": preload("res://player/Player.tscn"),
	"Enemy1": preload("res://enemies/enemy1/Enemy1.tscn"),
}

var ENTITIES_FOR_LEVEL = {
	"Level_001": {
		"Player": [Vector3(0, 1, 12)],
		"Enemy1": [
			Vector3(15, 3, -14),
			Vector3(10, 3, -12),
			Vector3(0, 3, -10),
			Vector3(0, 3, -12),
			Vector3(-10, 3, -12),
			Vector3(-15, 3, -14),
		]
	},
	"Level_002": {},
	"Level_003": {},
}

func get_mobs():
	return get_tree().get_nodes_in_group("mobs")

func spawn_for_level(level):
	level = "Level_" + str(level).pad_zeros(3)
	Console.log("Spawning enemies for " + level)
	
	#print(ENTITIES_FOR_LEVEL[level])
	for enemy_type in ENTITIES_FOR_LEVEL[level]:
		for pos in ENTITIES_FOR_LEVEL[level][enemy_type]:
			print(enemy_type, pos)
			spawn(enemy_type, pos)

func spawn(name, pos):
	var scene = ENTITIES[name].instance()
	scene.translate(pos)
	get_tree().current_scene.add_child(scene)

class Enemy1:
	static func spawn(pos):
		Entities.spawn("Enemy1", pos)
