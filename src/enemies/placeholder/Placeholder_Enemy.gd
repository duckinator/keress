extends RigidBody

const VIEW_DISTANCE = 20

const MASS = 150

var MAX_HEALTH = 100
var health = 0

var left_ray
var right_ray

var player_position_guess = Vector3(0, 0, 0)
var last_left = null
var last_right = null
var last_left_time = 0
var last_right_time = 0

func _ready():
	left_ray = $RayCast_Left
	right_ray = $RayCast_Right
	health = MAX_HEALTH
	self.mode = MODE_CHARACTER
	self.mass = MASS
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func die():
	get_tree().current_scene.mob_died(self)

func cleanup():
	# This can be expanded by adding a death animation and such later.
	queue_free()

func adjust_health(value):
	health = clamp(health + value, 0, MAX_HEALTH)
	print(str(self) + ".health = " + str(health))
	if health <= 0:
		die()

func vel_to_speed(vel):
	var x = abs(vel.x)
	var y = abs(vel.y)
	var z = abs(vel.z)
	return sqrt((x * x) + (y * y) + (z * z))

func impact_to_force(colider, colider_vel):
	var speed = vel_to_speed(colider_vel)
	return colider.MASS * speed

func _process_body_entered(body):
	if body.has_method("get_last_velocity"):
		var vel = body.get_last_velocity()
		var force = impact_to_force(body, vel)
		
		var height = $MeshInstance.mesh.height
		# If the player is on top of the enemy, it's a curb stomp.
		if floor(body.translation.y) > floor(self.translation.y + height):
			var gravity = Globals.get_total_gravity_for(self)
			force = impact_to_force(body, Vector3(vel.x, gravity.y, vel.z))
			var damage = ceil(force / 200)
			adjust_health(-damage)

func found_player(raycast, player, position):
	if raycast == left_ray:
		last_left_time = OS.get_ticks_msec()
		last_left = player
		if last_right == player:
			print("PLAYER IS GOING LEFT")
	
	if raycast == right_ray:
		last_right_time = OS.get_ticks_msec()
		last_right = player
		if last_left == player:
			print("PLAYER IS GOING RIGHT")

	var diff = abs(last_left_time - last_right_time)
	if diff > 100:
		print("    Pretty sure they're still in front of me.")
	else:
		print("    They took " + str(diff) + " milliseconds.")
	#print("  raycast  = " + str(raycast))
	#print("  position = " + str(position))

func search_for_player():
	#print("SEARCHING FOR PLAYER")
	pass

func found_object(raycast, object, position):
	print("FOUND OBJECT")
	print("  object = " + str(object))
	print("  position = " + str(position))