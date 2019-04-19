extends Node

const MENU_SCENE = preload("res://menus/Main_Menu.tscn")
const DEBUG_SCENE = preload("res://menus/Debug_Display.tscn")
var canvas_layer
var debug_display = null

func _ready():
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func _process(delta):
	pass

func set_debug(debug_on):
	if debug_on:
		if debug_display == null:
			debug_display = DEBUG_SCENE.instance()
			canvas_layer.add_child(debug_display)
	elif debug_display:
		debug_display.queue_free()
		debug_display = null