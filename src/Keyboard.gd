extends Node

# This file handles global keyboard input.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(_event):
	# TODO: Determine why there's no KEY_BACKTICK or similar?
	if Game.playing and Input.is_key_pressed(96):
		Console.toggle()
