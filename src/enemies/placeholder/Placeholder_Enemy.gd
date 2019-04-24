extends RigidBody

const NONE = 0
const TURN_LEFT = 1
const TURN_RIGHT = 2
var turn_state = NONE
const MOVE_FORWARD = 3
const MOVE_BACKWARD = 4
const MOVE_LEFT = 5
const MOVE_RIGHT = 6
var move_state = NONE

const VIEW_DISTANCE = 60

const MASS = 150

var MAX_HEALTH = 100
var health = 0

# Direction being looked at.
var dir = Vector3(0, 0, 0)
var goal_direction = null

var left_ray
var right_ray
var center_ray

var player_position_guess = Vector3(0, 0, 0)

func _ready():
	left_ray = $RayCast_Left
	right_ray = $RayCast_Right
	center_ray = $RayCast_Center
	health = MAX_HEALTH
	self.mode = MODE_CHARACTER
	self.mass = MASS
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func _process(delta):
	if turn_state == NONE:
		return
	
	if turn_state == TURN_LEFT:
		rotate_y(deg2rad(5))
	
	if turn_state == TURN_RIGHT:
		rotate_y(deg2rad(-5))

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

func noise_from(position, loudness):
	# If it was loud, it should be investigated.
	# If it wasn't, just glance over.
	if loudness >= 1:
		print("TODO: Look at the loud noise at " + str(position))
		#goal_direction = dir

func found_player(raycast, player, position):
	if center_ray.get_collider() == player:
		turn_state = NONE
		return
	
	if left_ray.get_collider() == player and right_ray.get_collider() != player:
		turn_state = TURN_LEFT
		return
	
	if left_ray.get_collider() != player and right_ray.get_collider() == player:
		turn_state = TURN_RIGHT
		return

func search_for_player():
	#print("SEARCHING FOR PLAYER")
	#turn_state = NONE
	pass

func found_object(raycast, object, position):
	#print("FOUND OBJECT")
	#print("  object = " + str(object))
	#print("  position = " + str(position))
	pass