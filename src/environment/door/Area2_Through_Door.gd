extends Area

func _ready():
	var err = connect("body_entered", self, "_process_body_entered")
	if err != OK:
		Console.log(err)

func _process_body_entered(body):
	if body is KinematicBody:
		get_parent().through()
