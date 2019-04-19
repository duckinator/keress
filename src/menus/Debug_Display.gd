extends Control

func _ready():
	$Panel/Label_OS.text = "OS: " + OS.get_name()
	$Panel/Label_Engine.text = "Godot version: " + Engine.get_version_info()["string"]

func _process(delta):
	$Panel/Label_FPS.text = "FPS: " + str(Engine.get_frames_per_second())