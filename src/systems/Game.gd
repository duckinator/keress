extends Node

signal pause
signal resume

const PAUSE_SCENE = preload("res://overlays/Pause_Popup.tscn")

var canvas_layer

func _ready():
	randomize()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func pause():
	canvas_layer.add_child(PAUSE_SCENE.instance())
	emit_signal("pause")

func resume():
	emit_signal("resume")

func quit():
	get_tree().quit()

func playing():
	return (get_tree().current_scene.name == "BlenderLevel")
