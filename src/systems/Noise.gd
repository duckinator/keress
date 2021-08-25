extends Node

signal event

func _ready():
	pass

func add_listener(node, function):
	connect("noise", node, function)

func emit(trans, sound, loudness):
	emit_signal("noise", trans, sound, loudness)
	Console.log('noise: trans=' + str(trans) + ', sound=' + str(sound) + ', loudness=' + str(loudness))

func _process(delta):
	pass
