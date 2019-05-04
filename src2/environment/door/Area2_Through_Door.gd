extends Area

func _ready():
	connect("body_entered", self, "_process_body_entered")

func _process_body_entered(body):
	if body is KinematicBody:
		get_parent().through()