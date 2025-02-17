extends Node

signal noise

func _ready():
	pass

func add_listener(node, function):
	var err = noise.connect(Callable(node, function))
	Console.error_unless_ok("Noise.connect(%s, %s)" % [var_to_str(node), var_to_str(function)], err)

func emit(trans, sound, loudness):
	noise.emit(trans, sound, loudness)
	#Console.debug('noise: trans=' + str(trans) + ', sound=' + str(sound) + ', loudness=' + str(loudness))

func _process(_delta):
	pass
