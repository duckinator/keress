extends Node

# Areas Of Interest system
# ========================
# Listens to events from systems that are of interest to enemies, such as Noise.
# Mobs register as listeners when they are spawned.
# When the level changes, +mobs+ and +areas+ both get cleared.
# 

signal event

const AOI_GRANULARITY = 10.0
const MAX_AREAS = 10

var mobs = []
var areas = []

func _ready():
	Game.connect("load_level", self, "clear")
	Noise.add_listener(self, "add_noise_aoi")

func clear():
	mobs = []
	areas = []

func add_mob(node):
	mobs.append(node)

func remove_mob(node):
	mobs.remove(mobs.find(node))

func add_noise_aoi(trans, _sound, _loudness):
	add_aoi(trans)

# Given +trans+, make it less precise in a predictable way, then add it to +areas+  if it's not in it already.
func add_aoi(trans):
	var rounded
	trans = trans.round()
	rounded = Vector3(trans.x - fmod(trans.x, AOI_GRANULARITY), trans.y - fmod(trans.y, AOI_GRANULARITY), trans.z - fmod(trans.z, AOI_GRANULARITY))
	if rounded in areas:
		return
	if len(areas) > MAX_AREAS:
		areas.pop_front()
	areas.append(rounded)
	Console.log('AOIs = ' + str(areas))

const MAX_DISTANCE = 20
var counter = 0.0
func _process(delta):
	if not Game.playing:
		return

	counter += delta
	if counter < 1:
		return
	else:
		counter = 0
	#Console.log("AreasOfInterest._process()")

	var distance
	for mob in mobs:
		if mob == null:
			continue
		for area in areas:
			Console.log("Attempting to find mob to investigate " + str(area) + "; trying " + str(mob))
			distance = mob.translation.distance_to(area)
			if distance < MAX_DISTANCE:
				Console.log("Having " + str(mob) + " investigate " + str(area))
				mob.investigate(area)
				areas.remove(areas.find(area))
				break

	# Prune null items.
	# I think these show up when mobs die? Not sure.
	for _idx in range(len(mobs)):
		var null_item = mobs.find(null)
		if null_item == -1:
			break
		mobs.remove(null_item)
