extends Spatial

var mobs = []
func _ready():
	# $Platform
	#spawn_enemy(Vector3(-48, 4, 60))
	#spawn_enemy(Vector3(-30, 4, 50))
	#spawn_enemy(Vector3(-48, 4, -60))
	#spawn_enemy(Vector3(-30, 4, -50))
	
	# $Platform_Left
	spawn_small_horde(Vector3(-100, -99, 164), Vector2(80, 80), 9)

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func can_open_door(door):
	return (not door.is_exit) or (len(mobs) == 0)

func opening_door(door):
	pass

func closing_door(door):
	pass

func through_door(door):
	pass

func mob_died(mob):
	mobs.remove(mobs.find(mob))
	mob.cleanup()

func spawn_enemy(pos):
	var scene = load("res://enemies/enemy1/Enemy1.tscn").instance()
	add_child(scene)
	scene.translate(pos)
	mobs.append(scene)

func acceptable_horde_member_position(coords, pos):
	if len(coords) == 0:
		return true
	return true # TODO

func rand_vec2_up_to(dimensions):
	return Vector2(rand_range(0, dimensions.x), rand_range(0, dimensions.y))

func remove_adjacent(available, dimensions, pos):
	var x = pos.x
	var y = pos.y
	for x2 in range(clamp(x - 8, 0, dimensions.x), clamp(x + 8, 0, dimensions.x)):
		var item = available.find(Vector2(x2, y))
		if item:
			Console.log("REMOVED: " + str(Vector2(x2, y)))
			available.remove(item)
		else:
			Console.log("NO ITEM: " + str(Vector2(x2, y)))
	for y2 in range(clamp(y - 8, 0, dimensions.y), clamp(y + 8, 0, dimensions.y)):
		for x2 in range(clamp(x - 4, 0, dimensions.x), clamp(x + 4, 0, dimensions.x)):
			var item = available.find(Vector2(x2, y2))
			if item:
				Console.log("REMOVED: " + str(Vector2(x2, y2)))
				available.remove(item)
			else:
				Console.log("NO ITEM: " + str(Vector2(x2, y2)))

func horde_coords(dimensions, horde_size):
	var available = []
	for x in range(0, int(dimensions.x)):
		for z in range(0, int(dimensions.y)):
			available.append(Vector2(x, z))
	
	var coords = []
	for idx in range(0, horde_size):
		var pos = available[rand_range(0, len(available))]
		available.remove(available.find(pos))
		remove_adjacent(available, dimensions, pos)
		coords.append(pos)
	return coords

func spawn_small_horde(center, dimensions, horde_size=null):
	if horde_size == null:
		horde_size = 9
	
	var coords = horde_coords(dimensions, horde_size)
	
	for idx in range(0, len(coords)):
		var pos2d = coords[idx]
		var pos = Vector3(center.x + pos2d.x, center.y, center.y + pos2d.y)
		Console.log(str(pos))
		spawn_enemy(pos)

func rand_sign():
	randomize()
	if rand_range(0, 100) > 50:
		return 1
	else:
		return -1

func meander(center, min_x, max_x, min_z, max_z):
	var pos = center
	pos.x += rand_range(min_x, max_x) * rand_sign()
	pos.z += rand_range(min_z, max_z) * rand_sign()
	return pos


