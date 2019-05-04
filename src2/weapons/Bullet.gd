extends RigidBody

const MASS = 80

# Bullet despawns after the specified lifespan, in seconds.
const BULLET_LIFESPAN = 5

const SPEED = 300

var next_impulse = null

var last_velocity = Vector3(0, 0, 0)

func _ready():
	var timer = Timer.new()
	timer.wait_time = BULLET_LIFESPAN
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start()

func _integrate_forces(state):
	if next_impulse:
		var impulse = next_impulse
		next_impulse = null
		apply_impulse(Vector3(0, 0, 0), impulse)

func get_last_velocity():
	return last_velocity

func fire(vel):
	print("VEL=" + str(vel))
	last_velocity = vel
	next_impulse = vel