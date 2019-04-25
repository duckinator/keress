extends RigidBody

# Bullet despawns after the specified lifespan, in seconds.
const BULLET_LIFESPAN = 5

func _ready():
	var timer = Timer.new()
	timer.wait_time = BULLET_LIFESPAN
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start()