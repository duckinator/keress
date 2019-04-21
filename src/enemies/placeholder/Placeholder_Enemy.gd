extends RigidBody

const MASS = 150

var MAX_HEALTH = 100
var health = 0

func _ready():
	health = MAX_HEALTH
	self.mode = MODE_CHARACTER
	self.mass = MASS
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _process_body_entered(body):
	if body.has_method("get_velocity"):
		var vel = body.get_velocity()
		print(vel)