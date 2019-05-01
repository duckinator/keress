extends RigidBody

const BULLET_SCENE = preload("res://weapons/Bullet.tscn")

var player

func _ready():
	self.mode = MODE_STATIC

func set_player(node):
	player = node

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

var fire_rate = 5 # per second
var fire_timeout = null
func fire():
	if fire_timeout != null:
		return
	
	fire_timeout = Timer.new()
	fire_timeout.connect("timeout", self, "_fire_timeout_reset")
	fire_timeout.wait_time = 1.0 / fire_rate
	add_child(fire_timeout)
	fire_timeout.start()
	
	# TODO: Figure out how to move the bullet starting position higher/lower based on where you look.
	var bullet = BULLET_SCENE.instance()
	
	var bullet_pos_offset = Vector3(0, -0.5, 0).normalized() # tweak as needed
	bullet.translate(bullet_pos_offset) # TODO: Make relative to direction being looked.
	
	add_child(bullet)
	
	#print(bullet.rotation_degrees, "; ", rotation_degrees, "; ", rotation_helper.rotation_degrees)
	
	# TODO: Figure out how to adjust the bullet angle based on looking up/down.
	#bullet.rotation_degrees.x = player.rotation_helper.rotation_degrees.x
	#bullet.rotation_degrees.y = player.rotation_degrees.y - 90
	#bullet.rotation_degrees.z = player.rotation_helper.rotation_degrees.z + 90
	
	var bullet_vel = Vector3(bullet.SPEED, 0, 0)
	print(rotation_degrees)
	#print("parent=" + str(player.translation))
	var rot = player.rotation_degrees
	print("rot=" + str(rot))
	#bullet.look_at_from_position(translation, translation + Vector3(0, 1, 0), Vector3(0, 1, 0))
	#bullet.look_at(get_transform().origin, Vector3(0,1,0))
	bullet_vel = bullet_vel.rotated(Vector3(1, 0, 0), deg2rad(-player.rotation_helper.rotation_degrees.x))
	bullet_vel = bullet_vel.rotated(Vector3(0, 1, 0), deg2rad(player.rotation_degrees.y + 90))
	bullet_vel = bullet_vel.rotated(Vector3(0, 0, 1), deg2rad(player.rotation_helper.rotation_degrees.z))
	
	#print("bullet velocity = " + str(bullet_vel))
	bullet.fire(bullet_vel)

func _fire_timeout_reset():
	remove_child(fire_timeout)
	fire_timeout = null