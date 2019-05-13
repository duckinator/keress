extends Spatial

signal noise

var mobs = []
func _ready():
	# $Platform
	spawn_horde(Vector3(-56, 3, 40), Vector2(30, 100), 3)
	spawn_horde(Vector3(-56, 3, -180), Vector2(30, 100), 3)
	
	# $Platform_Left
	spawn_horde(Vector3(-370, -24, 150), Vector2(280, 30), 20)
	# $Platform_Right
	spawn_horde(Vector3(-370, -24, -180), Vector2(280, 30), 20)
	
	# $Platform_Mid
	spawn_horde(Vector3(-220, -52, -182), Vector2(30, 400), 16)

func player_noise(trans, sound, loudness):
	trans = trans.round()
	emit_signal("noise", trans, sound, loudness)

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
	scene.navigation = $Navigation
	scene.player = $Player
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
		Console.log("MOB POS: " + str(pos2d))
		var pos = Vector3(center.x + pos2d.x, center.y, center.z + pos2d.y)
		Console.log("MOB AT: " + str(pos))
		spawn_enemy(pos)

