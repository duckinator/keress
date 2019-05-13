extends Node

var aois = []

func _ready():
	pass

func _process(delta):
	var scene = get_tree().current_scene
	if not scene.name.begins_with("Level_"):
		return
	var mobs = scene.mobs
	var current = mobs[rand_range(0, len(mobs))]
	for idx in range(0, len(aois)):
		var aoi = aois[idx]
		if current.translation.distance_to(aoi) < 100:
			current.check(aoi)
			aois.remove(idx)
			return

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