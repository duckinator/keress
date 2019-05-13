extends Node

var aois = []

func _ready():
	pass

func _process(delta):
	var scene = get_tree().current_scene
	if not scene.name.begins_with("Level_"):
		return
	var mobs = scene.mobs
	var mob = mobs[rand_range(0, len(mobs))]
	var current = null
	var current_distance = 0
	
	var hard_cap = 20
	for idx in range(0, len(aois)):
		var aoi = aois[idx]
		var aoi_distance = mob.translation.distance_to(aoi)
		if current == null or aoi_distance < current_distance:
			current = aoi
			current_distance = aoi_distance
		hard_cap -= 1
		if hard_cap <= 0:
			break
	if current != null:
		mob.check(current)
		aois.remove(aois.find(current))

func get_path_curve(start, end):
	var navigation = get_tree().current_scene.get_node("Navigation")
	var points = navigation.get_simple_path(start, end)
	if len(points) == 0:
		return
	var path = Curve3D.new()
	for point in points:
		point.y += 2 # HACK: idk why i need this. or if i still do.
		path.add_point(point)
	return path

func add_area_of_interest(mob, trans):
	trans = trans.round()
	if not trans in aois:
		Console.log("Added Area of Interest: " + str(trans))
		aois.append(trans)