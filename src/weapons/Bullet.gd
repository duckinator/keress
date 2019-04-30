extends RigidBody

const MASS = 80

# Bullet despawns after the specified lifespan, in seconds.
const BULLET_LIFESPAN = 5

const SPEED = 80

var last_velocity

func _ready():
	var timer = Timer.new()
	timer.wait_time = BULLET_LIFESPAN
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start()

func get_last_velocity():
	return last_velocity

func fire(vel):
	last_velocity = vel
	apply_impulse(Vector3(0, 0, 0), vel)