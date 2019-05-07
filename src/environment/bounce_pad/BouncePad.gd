extends RigidBody

export var assist: float = 2

func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func _process_body_entered(body):
	if not body is StaticBody and body.has_method("jump"):
		body.jump(assist)