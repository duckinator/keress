extends Node

func spawn(pos):
	Console.log("Enemies.spawn()")
	var scene = load("res://enemies/enemy1/Enemy1.tscn").instance()
	scene.translate(pos)
	get_tree().current_scene.add_child(scene)
