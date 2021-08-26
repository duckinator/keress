extends Node

signal event

var areas = []

func _ready():
	Game.connect("load_level", self, "clear")
	Noise.add_listener(self, "add_noise_aoi")

func add_listener(node, function):
	var err = connect("event", node, function)
	if err != OK:
		Console.log(err)

func add_noise_aoi(trans, _sound, _loudness):
	add_aoi(trans)

func add_aoi(trans):
	areas.append(trans)
	Console.log('AOI: trans=' + str(trans))

func _process(_delta):
	pass
