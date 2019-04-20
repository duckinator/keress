extends Spatial

const LEVEL_SCENE = "res://levels/ProgrammaticLevel.tscn"

var mobs = []
var grids
var current_level

func _ready():
	current_level = Settings.fetch("current_level", 1)
	load_level(current_level)
	Globals.in_game = true

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

func load_level_scene(next):
	Settings.store("current_level", next)
	self.queue_free()
	Globals.load_new_scene(LEVEL_SCENE)

func load_level(level):
	var data = load_level_data(level)
	if not data:
		print("ERROR: load_level(): data is null")
		return
	var result = build_grids(data)
	$Player.global_translate(result[0])
	grids = result[1]

	for grid in grids:
		add_child(grid)

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
	print("translation=" + str(translation))
	print("rotation=" + str(rotation))
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
	
	if not lines[1].begins_with("r "):
		print("ERROR: fill_grid() expected second line to start with 'r '.")
		return null
	
	rot = str2vec3(lines[1].split(" ", false, 1)[1])
	
	if not lines[2].begins_with("d "):
		print("ERROR: fill_grid() expected third line to start with 'd '.")
		return null
	
	var grid = create_grid(trans, rot)
	
	for idx in range(2, len(lines) - 1):
		var x = idx - 2
		var line = lines[idx]
		for z in range(0, len(line) - 1):
			if line[z] != '-':
				grid.set_cell_item(x, 0, z, int(line[z]))
	return grid

func build_grids(data):
	data = remove_comments(data)
	var start_trans
	
	var lines = strip_all(data.split("\n"))
	var start = lines[0]
	lines.remove(0)
	var gs = ("\n" + lines.join("\n")).split("\nt ")
	var result = []
	
	if start.begins_with("start "):
		start_trans = str2vec3(start.split("start ")[1])
	else:
		print("ERROR: build_grids(): First line was not not a 'start' line")
		return null

	for g in gs:
		result.append(grid("t " + g))
	return [start_trans, result]

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
