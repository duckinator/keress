extends Node

var enabled = false setget _set_enabled

const DEBUG_SCENE = preload("res://overlays/DebugOverlay.tscn")

var canvas_layer

func _ready():
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	enabled = "--debug" in OS.get_cmdline_args() or Settings.fetch("debug")

	var err = Game.connect("resume", self, "add_overlay_if_enabled")
	if err != OK:
		Console.log(str(err))

func add_overlay_if_enabled():
	if enabled and Game.playing() and not canvas_layer.has_node("DebugOverlay"):
		canvas_layer.add_child(DEBUG_SCENE.instance())

func _set_enabled(_value):
	add_overlay_if_enabled()
