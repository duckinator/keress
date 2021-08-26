extends Area

func _ready():
	var err
	err = connect("body_entered", self, "_process_body_entered")
	if err != OK:
		Console.log(err)
	err = connect("body_exited", self, "_process_body_exited")
	if err != OK:
		Console.log(err)

func _process_body_entered(body):
	if body is KinematicBody:
		get_parent().open()

func _process_body_exited(body):
	if body is KinematicBody:
		get_parent().close()
