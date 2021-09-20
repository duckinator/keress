extends Node

# Areas Of Interest system
# ========================
# Listens to events from systems that are of interest to enemies, such as Noise.
# Mobs register as listeners when they are spawned.
# When the map changes, +mobs+ and +areas+ both get cleared.

const AOI_GRANULARITY = 5.0
const MAX_AREAS = 10

var areas = []

func _ready():
	var err = MapManager.connect("load_map", self, "clear")
	Console.error_unless_ok("MapManager.connect('load_map)' failed", err)
	Noise.add_listener(self, "add_noise_aoi")

func clear(_map):
	areas = []

func add_noise_aoi(trans, _sound, _loudness):
	add_aoi(trans)

# Given +trans+, make it less precise in a predictable way, then add it to +areas+  if it's not in it already.
func add_aoi(trans):
	var rounded
	rounded = Vector3(trans.x - fmod(trans.x, AOI_GRANULARITY), trans.y - fmod(trans.y, AOI_GRANULARITY), trans.z - fmod(trans.z, AOI_GRANULARITY))
	if rounded in areas:
		return
	if len(areas) > MAX_AREAS:
		areas.pop_front()
	areas.append(rounded)
	Console.log('AOIs = ' + str(areas))

var counter = 0.0
func _process(delta):
	var mobs = get_tree().get_nodes_in_group("mobs")
	if not Game.playing() or len(mobs) == 0 or len(areas) == 0:
		return

	counter += delta
	if counter < 1:
		return
	else:
		counter = 0

	var area = areas[0]
	var mob = mobs[0]
	var distance = INF

	for current_mob in mobs:
		var current_distance = current_mob.translation.distance_to(area)
		if current_distance < distance:
			mob = current_mob
			distance = current_distance

	Console.log("Having " + str(mob) + " (" + mob.name + ") investigate " + str(area))
	mob.investigate(area)
	areas.remove(areas.find(area))
