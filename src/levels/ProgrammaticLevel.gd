extends Spatial

const LEVEL_SCENE = "res://levels/ProgrammaticLevel.tscn"

const NOISE_DROPOFF = 15

var current_doors = []
var current_mobs = []
var current_grids = []

var next_doors = []
var next_mobs = []
var next_grids = []
var next_entry_line = null
var next_entry_line_offset = null
var next_queued = false

var second_or_later_level = false

var current_level
var next_level

var navigation

func _ready():
	navigation = $Navigation
	current_level = Settings.fetch("current_level", 1)
	var data = load_level(current_level)
	
	current_doors = data["doors"]
	current_mobs = data["mobs"]
	current_grids = data["grids"]
	$Player.global_translate(data["start"])
	add_entry_door()
	second_or_later_level = true
	
	Globals.in_game = true

func get_path(start, end):
	var points = navigation.get_simple_path(start, end)
	if len(points) == 0:
		return
	
	var path = Curve3D.new()
	for point in points:
		point.y += 2 # HACK: idk why i need this.
		path.add_point(point)
	return path

func _process(delta):
	if Globals.reload_level:
		Globals.load_new_scene(LEVEL_SCENE)
		queue_free()
		Globals.reload_level = false

func _input(event):
	if not Settings.fetch("debug", false):
		return
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F4:
		if load_level(current_level - 1) == null:
			print("WARNING: No previous level (" + str(current_level - 1) + ") to load.")
			return
		print("DEBUG: Loading previous level: " + str(current_level - 1))
		Settings.store("current_level", current_level - 1)
		Globals.reload_level = true

	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F5:
		print("DEBUG: Reloading level " + str(current_level))
		Globals.reload_level = true

	if event is InputEventKey and event.pressed and event.scancode == KEY_F6:
		if load_level(current_level + 1) == null:
			print("WARNING: No next level (" + str(current_level + 1) + ") to load.")
			return
		print("DEBUG: Loading next level: " + str(current_level + 1))
		Settings.store("current_level", current_level + 1)
		Globals.reload_level = true

func preload_next_level():
	if next_queued:
		print("WARNING: preload_next_level(): Next level already loaded!")
		return
	
	next_queued = true
	next_level = current_level + 1
	var offset = null
	var door_rotation = null
	print(current_doors)
	
	var exit_door_pos = null
	var next_level_data = load_level_data(next_level)
	if next_level_data == null:
		print("preload_next_level(): Level #" + str(next_level) + " does not exist.")
		return
	
	var lines = next_level_data.split("\n")
	for line in lines:
		if not " " in line:
			continue
		var parts = strip_all(line.strip_edges().split(" ", false, 1))
		if parts[0] != "entry":
			continue
		next_entry_line = line.split(" ", false, 1)[1]
		
		var parts2 = strip_all(parts[1].split(";"))
		offset = str2vec3(parts2[0])
		
		parts2.remove(0)
		for part in parts2:
			if not "=" in part:
				continue
			var parts3 = part.split("=", false, 1)
			if parts3[0] == "rotation":
				door_rotation = parts3[1]
	
	if offset == null:
		print("ERROR: offset == null for level #" + str(next_level))
		return
	
	if door_rotation == null:
		door_rotation = Vector3(0, 0, 0)
	
	for door in current_doors:
		if door.is_exit:
			offset.x = door.translation.x - offset.x
			offset.y = door.translation.y - offset.y
			offset.z = door.translation.z + 2
	next_entry_line_offset = offset
	var data = load_level(next_level, offset)
	next_doors = data["doors"]
	next_mobs = data["mobs"]
	next_grids = data["grids"]
	return data

func switch_to_next_level():
	Settings.store("current_level", next_level)
	var prev_mobs = current_mobs
	var prev_grids = current_grids
	var prev_doors = current_doors
	
	current_mobs = next_mobs
	current_grids = next_grids
	current_doors = next_doors
	current_level = next_level
	next_mobs = []
	next_grids = []
	next_doors = []
	next_level = null
	unload_level(prev_mobs, prev_grids, prev_doors)
	add_entry_door()
	next_queued = false
	for mob in current_mobs:
		mob.set_process(true)

func unload_level(mobs, grids, doors):
	for mob in mobs:
		mob.queue_free()
	for grid in grids:
		# TODO: Figure out why we're getting a null grid at the start.
		if grid != null:
			grid.queue_free()
	for door in doors:
		door.queue_free()

func load_level(level, offset=null):
	if offset == null:
		offset = Vector3(0, 0, 0)
	
	var data = load_level_data(level)
	if not data:
		print("ERROR: load_level(): data is null")
		return
	var result = build_grids(data, offset)
	var grids = result[0]
	var start = result[1]
	var light = result[2]
	var doors_dict = result[3]
	var doors = []
	
	if light:
		$WorldEnvironment.environment.ambient_light_energy = light

	for grid in grids:
		navigation.add_child(grid)
	
	var exit
	for door in doors_dict:
		var door_scene = add_door(door)
		if door["exit"]:
			exit = door_scene
		doors.append(door_scene)
	
	
	var mob_pos = exit.translation - offset + Vector3(0, 0, -2)
	print("mob_pos = " + str(mob_pos))
	var mobs = [
		Globals.spawn_scene("enemies/placeholder/Placeholder_Enemy", apply_offset(mob_pos, offset))
	]
	for mob in mobs:
		#mob.set_process(false)
		add_child(mob)
	
	return {
		"doors": doors,
		"grids": grids,
		"light": light,
		"mobs": mobs,
		"start": start,
	}

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

func grid(data, offset):
	data = remove_comments(data)
	var lines = strip_all(data.strip_edges().split("\n"))
	var trans = null
	var rot = null
	var size = null
	
	if not lines[0].begins_with("t "):
		print("ERROR: fill_grid() expected first line to start with 't '.")
		return null

	trans = str2vec3(lines[0].split(" ", false, 1)[1])
	trans = apply_offset(trans, offset)
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

func build_grids(data, offset):
	data = remove_comments(data)
	var start_trans = Vector3(0, 0, 0)
	var light = null
	var exit = null
	var exit_rotation = 0
	var doors = []
	
	var lines = strip_all(data.split("\n"))
	
	var to_remove = []
	for idx in range(0, len(lines)):
		var line = lines[idx]
		if not " " in line:
			continue
		var parts = line.split(" ", false, 1)
		if parts[0] == "start":
			start_trans = apply_offset(str2vec3(parts[1]), offset)
			to_remove.append(line)
		if parts[0] == "light":
			light = float(parts[1])
			to_remove.append(line)
		if parts[0] == "door" or parts[0] == "entry":
			if parts[0] == "entry" and second_or_later_level:
				# If this isn't the first level loaded, don't add an entry
				# door, since it'll overlap with the last exit door.
				continue
			doors.append(parse_door(parts[1], offset, parts[0] == "entry"))
	
	for line in to_remove:
		var idx = Array(lines).find(line)
		lines.remove(idx)
	
	var gs = ("\n" + lines.join("\n")).split("\nt ")
	var result = []

	for g in gs:
		result.append(grid("t " + g, offset))
	return [result, start_trans, light, doors]

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

func parse_door(line, offset, entry_door=false):
	# default values
	var door = {
		"exit": false,
		"locked": false,
		"rotation": 0,
		"entry": entry_door,
	}
	
	if entry_door:
		door["locked"] = true
	
	var parts = strip_all(line.split(";"))
	door["position"] = str2vec3(parts[0])
	parts.remove(0)
	
	for part in parts:
		var key_val = strip_all(part.split("=", false, 1))
		var key = key_val[0]
		var val = key_val[1]
		if key in ["rotation"]:
			val = float(val)
		elif val == "true":
			val = true
		elif val == "false":
			val = false
		door[key] = val
	
	door["position"] = apply_offset(door["position"], offset)
	
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
	
	# If it's not an exit, always let them go through.
	if not door.is_exit:
		return true
	
	# If it is a level exit, make sure there's no remaining mobs.
	return len(current_mobs) == 0

func through_door(door):
	if door.is_exit:
		switch_to_next_level()

func opening_door(door):
	print("Door opened: " + str(door))
	preload_next_level()

func closing_door(door):
	print("Door closed: " + str(door))

func mob_died(mob):
	if not mob in current_mobs:
		print("WARNING: Got message about " + str(mob) + ", which we aren't tracking")
		return
	
	current_mobs.remove(current_mobs.find(mob))
	mob.cleanup()

func add_door(door):
	var scene = Globals.spawn_scene("environment/door/Door", door["position"])
	next_doors.append(scene)
	scene.is_exit = door["exit"]
	scene.locked = door["locked"]
	scene.rotate_y(deg2rad(door["rotation"]))
	return scene

func add_entry_door():
	if next_entry_line == null:
		return
	print(next_entry_line)
	print(next_entry_line_offset)
	var door = add_door(parse_door(next_entry_line, next_entry_line_offset, true))
	current_doors.append(door)
	add_child(door)

func exit_door():
	for door in current_doors:
		if door.is_exit:
			return door
	return null

func apply_offset(vec, offset):
	return Vector3(vec.x + offset.x, vec.y + offset.y, vec.z + offset.z)

func player_noise(pos, loudness):
	for mob in current_mobs:
		var mob_pos = mob.translation
		var distance = mob_pos.distance_to(pos)
		loudness *= (NOISE_DROPOFF / distance)
		mob.noise_from(pos, loudness)