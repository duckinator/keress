extends Node

func _spawn(name, pos):
	var capitalized_name = name
	capitalized_name[0] = capitalized_name[0].to_upper()
	var scene = load("res://enemies/" + name + "/" + capitalized_name + ".tscn").instance()
	scene.translate(pos)
	get_tree().current_scene.add_child(scene)

class Enemy1:
	static func spawn(pos):
		Enemies._spawn("enemy1", pos)
