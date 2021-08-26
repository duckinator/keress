extends Node

signal noise

func _ready():
	pass

func add_listener(node, function):
	var err = connect("noise", node, function)
	if err != OK:
		Console.log(err)

func emit(trans, sound, loudness):
	emit_signal("noise", trans, sound, loudness)
	#Console.debug('noise: trans=' + str(trans) + ', sound=' + str(sound) + ', loudness=' + str(loudness))

func _process(_delta):
	pass
