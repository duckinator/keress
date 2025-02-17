extends Node

signal pausing
signal resuming

const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")

var canvas_layer

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func pause():
	canvas_layer.add_child(PAUSE_SCENE.instantiate())
	pausing.emit()

func resume():
	resuming.emit()

func quit():
	get_tree().quit()

func playing():
	var scene = get_tree().current_scene
	return (scene != null) && (scene.name == "BlenderLevel")
