extends Spatial

const LEVEL_SCENE = "res://levels/ProgrammaticLevel.tscn"

var doors = []
var mobs = []
var grids
var current_level

func _ready():
	current_level = Settings.fetch("current_level", 1)
	load_level(current_level)
	Globals.in_game = true
	
	mobs.append(Globals.spawn_scene("enemies/placeholder/Placeholder_Enemy", Vector3(10, 3, 10)))

func _process(delta):
	if Globals.reload_level:
		load_level(current_level)

func _input(event):
	if not Settings.fetch("debug", false):
		return
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F4:
		print("DEBUG: Loading previous level: " + str(current_level - 1))
		load_level_scene(current_level - 1)
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F5:
		print("DEBUG: Reloading level " + str(current_level))
		load_level_scene(current_level)
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F6:
		print("DEBUG: Loading next level: " + str(current_level + 1))
		load_level_scene(current_level + 1)

func next_level():
	var next = current_level + 1
	load_level_scene(next)

func unload_level():
	for mob in mobs:
		mob.queue_free()
	for grid in grids:
		# TODO: Figure out why we're getting a null grid at the start.
		if grid != null:
			grid.queue_free()
	for door in doors:
		door.queue_free()
	self.queue_free()

func load_level_scene(next):
	Settings.store("current_level", next)
	unload_level()
	Globals.load_new_scene(LEVEL_SCENE)

func load_level(level):
	var data = load_level_data(level)
	if not data:
		print("ERROR: load_level(): data is null")
		return
	var result = build_grids(data)
	grids = result[0]
	$Player.global_translate(result[1])
	var light = result[2]
	var doors_ = result[3]
	
	if light:
		$WorldEnvironment.environment.ambient_light_energy = light

	for grid in grids:
		add_child(grid)
	
	for door in doors_:
		add_door(door)

func load_level_data(level):
	var filename = "res://levels/level-" + str(level).pad_zeros(3) + ".lvl"
	print("Loading " + filename)
	var file = File.new()
	if not file.file_exists(filename):
		print("ERROR: load_level_data(): no such file: " + filename)
		return null
	file.open(filename, File.READ)
	return file.get_as_text()

func create_grid(translation, rotation):
	var grid = $DummyGridMap.duplicate()
	grid.global_translate(translation)
	#grid.global_rotate(rotation, 1)
	#print("translation=" + str(translation))
	#print("rotation=" + str(rotation))
	grid.rotation_degrees.x = rotation.x
	grid.rotation_degrees.y = rotation.y
	grid.rotation_degrees.z = rotation.z
	grid.visible = true
	return grid

func grid(data):
	data = remove_comments(data)
	var lines = strip_all(data.strip_edges().split("\n"))
	var trans = null
	var rot = null
	var size = null
	
	if not lines[0].begins_with("t "):
		print("ERROR: fill_grid() expected first line to start with 't '.")
		return null

	trans = str2vec3(lines[0].split(" ", false, 1)[1])
	lines.remove(0)
	
	if not lines[0].begins_with("r "):
		print("ERROR: fill_grid() expected second line to start with 'r '.")
		return null
	
	rot = str2vec3(lines[0].split(" ", false, 1)[1])
	lines.remove(0)
	
	if not lines[0].begins_with("d "):
		print("ERROR: fill_grid() expected third line to start with 'd '.")
		return null
	lines.remove(0)
	
	var grid = create_grid(trans, rot)
	
	for idx in range(0, len(lines)):
		var x = idx
		var line = lines[idx]
		for z in range(0, len(line)):
			if line[z] != '-':
				grid.set_cell_item(x, 0, z, int(line[z]))
	return grid

func build_grids(data):
	data = remove_comments(data)
	var start_trans = Vector3(0, 0, 0)
	var light = null
	var exit = null
	var exit_rotation = 0
	var doors_ = []
	
	var lines = strip_all(data.split("\n"))
	
	var to_remove = []
	for idx in range(0, len(lines)):
		var line = lines[idx]
		if not " " in line:
			continue
		var parts = line.split(" ", false, 1)
		if parts[0] == "start":
			start_trans = str2vec3(parts[1])
			to_remove.append(line)
		if parts[0] == "light":
			light = float(parts[1])
			to_remove.append(line)
		if parts[0] == "door":
			doors_.append(parse_door(parts[1]))
	
	for line in to_remove:
		var idx = Array(lines).find(line)
		lines.remove(idx)
	
	var gs = ("\n" + lines.join("\n")).split("\nt ")
	var result = []

	for g in gs:
		result.append(grid("t " + g))
	return [result, start_trans, light, doors_]

func str2vec3(s, sep=" "):
	var parts = s.strip_edges().split(sep)
	if len(parts) != 3:
		print("ERROR: len(parts) is " + str(len(parts)) + "; expected 3.")
		print("       parts = <" + str(parts) + ">")
		return null
	return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))

func strip_all(strs):
	for idx in range(0, len(strs) - 1):
		strs[idx] = strs[idx].strip_edges()
	return strs

func remove_comments(data):
	var lines = data.split("\n")
	var result = ""
	for line in lines:
		var stripped_line = line.strip_edges()
		if len(stripped_line) > 0 and stripped_line[0] != "#":
			result += line + "\n"
	return result

func parse_door(line):
	# default values
	var door = {
		"exit": false,
		"locked": false,
		"rotation": 0,
	}
	
	var parts = strip_all(line.split(";"))
	door["position"] = str2vec3(parts[0])
	parts.remove(0)
	
	for part in parts:
		var key_val = strip_all(part.split("=", false, 1))
		var key = key_val[0]
		var val = key_val[1]
		print(val)
		if key in ["rotation"]:
			val = float(val)
		elif val == "true":
			val = true
		elif val == "false":
			val = false
		door[key] = val
	
	return door

# FIXME: set_gravity() is broken.
#func set_gravity(strength, vec):
#	var space = get_world().get_space()
#	PhysicsServer.area_set_param(space, PhysicsServer.AREA_PARAM_GRAVITY, strength)
#	PhysicsServer.area_set_param(space, PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, vec)

func can_open_door(door):
	# If it's locked, always, return false.
	if door.locked:
		return false
	
	# If it's not a level exit, always let them go through.
	if not door.level_exit:
		return true
	
	# If it is a level exit, make sure there's no remaining mobs.
	return len(mobs) == 0

func opening_door(door):
	print("Door opened: " + str(door))

func closing_door(door):
	print("Door closed: " + str(door))

func mob_died(mob):
	if not mob in mobs:
		print("WARNING: Got message about " + str(mob) + ", which we aren't tracking")
		return
	
	mobs.remove(mobs.find(mob))
	mob.cleanup()

func add_door(door):
	var scene = Globals.spawn_scene("environment/door/Door", door["position"])
	print(door)
	doors.append(scene)
	scene.level_exit = door["exit"]
	scene.locked = door["locked"]
	scene.rotate_y(deg2rad(door["rotation"]))