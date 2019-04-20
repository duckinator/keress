extends Spatial

var mobs = []
var grids
func _ready():
	var result = build_grids("""
	start 4 0 2
	
	t 0 0 0
	r 0 0 0
	d Floor
	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
	""")
	$Player.global_translate(result[0])
	grids = result[1]

	#var Ceil = new_grid(Vector3(0, 30, 0), Vector3(0, 180, 180))
	#var Left = new_grid(Vector3(0, 0, -50), Vector3(90, 180, 180))
	#var Right = new_grid(Vector3(0, 0, 50), Vector3(-90, 180, 180))
	#var Start = new_grid(Vector3(-5, 0, 0), Vector3(-90, 180, 90))
	#var End = new_grid(Vector3(400, 0, 0), Vector3(-90, -180, -90))

	for grid in grids:
		add_child(grid)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func create_grid(translation, rotation):
	var grid = $DummyGridMap.duplicate()
	grid.translation.x = translation.x
	grid.translation.y = translation.y
	grid.translation.z = translation.z
	grid.rotation_degrees.x = rotation.x
	grid.rotation_degrees.y = rotation.y
	grid.rotation_degrees.z = rotation.z
	grid.visible = true
	return grid

func grid(data):
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
	
	print("trans=" + str(trans) + "\nrot =" + str(rot))
	var grid = create_grid(trans, rot)
	
	for idx in range(3, len(lines) - 1):
		var x = idx - 3
		var line = lines[idx]
		for z in range(0, len(line) - 1):
			grid.set_cell_item(x, 0, z, int(line[z]))
	return grid

func build_grids(data):
	var start_trans
	
	var gs = strip_all(strip_all(data.split("\n")).join("\n").split("\n\n"))
	var result = []

	for g in gs:
		if g.begins_with("start "):
			start_trans = str2vec3(g.split("start ")[1])
		else:
			result.append(grid(g))
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