extends Node

signal event

const AOI_GRANULARITY = 20.0
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

const MAX_DISTANCE = 10
func _process(_delta):
	var distance
	for mob in mobs:
		if mob == null:
			continue
		for area in areas:
			distance = mob.translation.distance_to(area)
			if distance < MAX_DISTANCE:
				mob.investigate(area)
				break

	# Prune null items.
	# I think these show up when mobs die? Not sure.
	for _idx in range(len(mobs)):
		mobs.remove(mobs.find(null))
