extends Node

signal noise

func _ready():
	pass

func add_listener(node, function):
	var err = connect("noise", node, function)
	Console.error_unless_ok("Noise.connect(%s, %s)" % [var2str(node), var2str(function)], err)

func emit(trans, sound, loudness):
	emit_signal("noise", trans, sound, loudness)
	#Console.debug('noise: trans=' + str(trans) + ', sound=' + str(sound) + ', loudness=' + str(loudness))

func _process(_delta):
	pass
