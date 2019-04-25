extends RigidBody

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
var left_side_ray
var right_side_ray

var player_position_guess = Vector3(0, 0, 0)

const PATROL = 0
const SEARCH = 1
const ATTACK = 3
const DEFEND = 4
const EVADE = 5

var state_names = ["PATROL", "SEARCH", "ATTACK", "DEFEND", "EVADE"]

#var transitions = [
#	# Patrol
#	["SEARCH", "ATTACK", "DEFEND"],
#	# Search
#	["ATTACK", "DEFEND"],
#	# Attack
#	["SEARCH", "DEFEND"],
#	# Defend
#	["SEARCH", "ATTACK"],
#]

var state = PATROL

var senses = {
	"vision": {
		"left": null, "center": null, "right": null,
		"left-side": null, "right-side": null,
	},
	"hearing": [],
}

var map
var player
var target

var backoff_distance = 6

func _ready():
	map = get_node('..')
	player = get_node("../Player")
	target = player # The player is the default target.
	left_ray = $RayCast_Left
	right_ray = $RayCast_Right
	center_ray = $RayCast_Center
	left_side_ray = $RayCast_Left_Side
	right_side_ray = $RayCast_Right_Side
	health = MAX_HEALTH
	self.mode = MODE_CHARACTER
	self.mass = MASS
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func _process(delta):
	state_transition(state, delta)

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
		state = ATTACK # We bumped into the player!
		var vel = body.get_last_velocity()
		var force = impact_to_force(body, vel)
		
		var height = $MeshInstance.mesh.height
		# If the player is on top of the enemy, it's a curb stomp.
		if floor(body.translation.y) > floor(self.translation.y + height):
			state = EVADE
			var gravity = Globals.get_total_gravity_for(self)
			force = impact_to_force(body, Vector3(vel.x, gravity.y, vel.z))
			var damage = ceil(force / 200)
			adjust_health(-damage)

func noise_from(position, loudness):
	# If it was loud, it should be investigated.
	if loudness >= 1:
		print("TODO: Handle the loud noise at " + str(position))

var last_state = null
func state_transition(current_state, delta):
	if current_state == PATROL:
		patrol(last_state, delta)
	elif current_state == SEARCH:
		search(last_state, delta)
	elif current_state == ATTACK:
		attack(last_state, delta)
	elif current_state == DEFEND:
		defend(last_state, delta)
	elif current_state == EVADE:
		evade(last_state, delta)
	else:
		printerr("UNKNOWN STATE: " + str(current_state))
	
	last_state = current_state

func obstructed(ray):
	var obj = senses["vision"][ray]
	if obj == null:
		return false
	
	var path = map.get_path(translation, obj.translation)
	print(path, path.get_baked_length())
	return path.get_baked_length() <= 40

func see_player(ray):
	var obj = senses["vision"][ray]
	return obj != null and obj is KinematicBody

var patrol_offset
var patrol_path
func patrol(last_state, delta):
	Debug.print("PATROLING (" + str(self) + ")")
	target = get_parent().exit_door()
	chase(last_state, true, true)

func search(last_state, delta):
	Debug.print("SEARCHING")

func attack(last_state, delta):
	Debug.print("ATTACKING (" + str(self) + ")")
	target = player
	chase(last_state)

var chase_offset
var chase_path
var last_target_translation = null
func chase(last_state, rotated=false, meander=false):
	var need_new_path = false
	var should_move = true
	
	var distance_check = map.get_path(translation, target.translation)
	if state != last_state or chase_path == null or last_target_translation == null:
		need_new_path = true
	elif distance_check.get_baked_length() >= backoff_distance:
		need_new_path = (chase_path.get_baked_length() - chase_offset) <= 2
	else:
		# We are at or closer than the backoff distance; no need to move.
		should_move = false
	
	if need_new_path:
		Debug.print("  UPDATING PATH")
		last_target_translation = target.translation
		chase_path = map.get_path(translation, target.translation)
		chase_offset = 0
	
	if should_move:
		translation = chase_path.interpolate_baked(chase_offset)
		chase_offset += 0.25
	
	#if rotated:
	#	rotate(Vector3(0, 1, 0), rand_range(85, 95))
	
	if see_player("left") or see_player("center") or see_player("right"):
		target = player
		state = ATTACK

func defend(last_state, delta):
	Debug.print("DEFENDING")

func evade(last_state, delta):
	Debug.print("EVADING")



func found_player(raycast, player, position):
	senses["vision"][raycast_name(raycast)] = player

func found_nothing(raycast):
	senses["vision"][raycast_name(raycast)] = null

func found_object(raycast, object, position):
	senses["vision"][raycast_name(raycast)] = object


# TODO: Add left_side_ray and right_side_ray.
func raycast_name(raycast):
	if raycast == left_ray:
		return "left"
	elif raycast == right_ray:
		return "right"
	elif raycast == center_ray:
		return "center"
	elif raycast == left_side_ray:
		return "left-side"
	elif raycast == right_side_ray:
		return "right-side"
	else:
		print("UNKNOWN RAYCAST: " + str(raycast))
		return "UNKNOWN"