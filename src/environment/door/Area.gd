extends Area

func _ready():
	connect("body_entered", self, "_process_body_entered")
	connect("body_exited", self, "_process_body_exited")

func _process_body_entered(body):
	if body is KinematicBody:
		get_parent().open()

func _process_body_exited(body):
	if body is KinematicBody:
		get_parent().close()