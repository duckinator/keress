extends Node

var all setget , get_mobs

func get_mobs():
	return get_tree().get_nodes_in_group("mobs")

func _spawn(name, pos):
	var capitalized_name = name
	capitalized_name[0] = capitalized_name[0].to_upper()
	var scene = load("res://enemies/" + name + "/" + capitalized_name + ".tscn").instance()
	scene.translate(pos)
	get_tree().current_scene.add_child(scene)

class Enemy1:
	static func spawn(pos):
		Mobs._spawn("enemy1", pos)
