extends Node

func spawn(pos):
	var map = get_tree().current_scene
	var scene = load("res://enemies/enemy1/Enemy1.tscn").instance()
	map.add_child(scene)
	scene.translate(pos)
	map.mobs.append(scene)
	scene.navigation = map.get_node('Navigation')
	scene.player = map.get_node('Player')
	connect("noise", scene, "heard_noise")

func remove_adjacent(available, dimensions, pos):
	var x_spacing = clamp(dimensions.x / 4, 1, 8)
	var y_spacing = clamp(dimensions.y / 4, 1, 8)
	for item in available:
		if (abs(item.x - pos.x) < x_spacing) or (abs(item.y - pos.y) < x_spacing):
			available.remove(available.find(item))

func horde_coords(dimensions, horde_size):
	var available = []
	for x in range(0, int(dimensions.x)):
		for z in range(0, int(dimensions.y)):
			available.append(Vector2(x, z))
	
	var coords = []
	for idx in range(0, horde_size):
		if len(available) == 0:
			break
		var pos = available[rand_range(0, len(available))]
		available.remove(available.find(pos))
		remove_adjacent(available, dimensions, pos)
		coords.append(pos)
	return coords

func spawn_horde(center, dimensions, horde_size=null):
	if horde_size == null:
		horde_size = 9
	
	var coords = horde_coords(dimensions, horde_size)
	
	for idx in range(0, len(coords)):
		var pos2d = coords[idx]
		var pos = Vector3(center.x + pos2d.x, center.y, center.z + pos2d.y)
		Console.log("MOB AT: " + str(pos))
		spawn(pos)
