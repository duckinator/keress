extends RigidBody

const VIEW_DISTANCE = 60

const MASS = 150

var MAX_HEALTH = 200
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
var target_translation

var backoff_distance = 6

var state_change_cooldown_timer
var can_change_state

var evade_cooldown_timer

func _ready():
	map = get_node('..')
	player = get_node("../Player")
	target = player # The player is the default target.
	left_ray = $RayCast_Left
	right_ray = $RayCast_Right
	center_ray = $RayCast_Center
	left_side_ray = $RayCast_Left_Side
	right_side_ray = $RayCast_Right_Side
	
	state_change_cooldown_timer = Timer.new()
	state_change_cooldown_timer.one_shot = true
	state_change_cooldown_timer.connect("timeout", self, "_state_change_cooldown_end")
	_state_change_cooldown_start()
	
	evade_cooldown_timer = Timer.new()
	evade_cooldown_timer.one_shot = true
	evade_cooldown_timer.connect("timeout", self, "_evade_cooldown_end")
	
	can_change_state = true
	
	health = MAX_HEALTH
	self.mode = MODE_CHARACTER
	self.mass = MASS
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func _state_change_cooldown_start():
	can_change_state = false
	state_change_cooldown_timer.wait_time = rand_range(1, 5)
	state_change_cooldown_timer.start()

func _state_change_cooldown_end():
	can_change_state = true

func evade_cooldown_start():
	evade_cooldown_timer.wait_time = rand_range(3, 20)
	evade_cooldown_timer.start()

func _evade_cooldown_end():
	_state_change_cooldown_end()
	set_state(PATROL)

func set_state(new_state):
	if can_change_state:
		_state_change_cooldown_start()
		state = new_state

func get_state():
	return state

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

func impact_to_force(collider, collider_vel):
	var speed = vel_to_speed(collider_vel)
	return collider.MASS * speed

func force_to_damage(force):
	return ceil(force / 200)

func impact_to_damage(collider, collider_vel):
	var force = impact_to_force(collider, collider_vel)
	return force_to_damage(force)

func _process_body_entered(body):
	if not body.has_method("get_last_velocity"):
		return
	
	if body is RigidBody:
		var vel = body.get_last_velocity()
		var damage = impact_to_damage(body, vel)
		adjust_health(-damage)
	
	if body is KinematicBody:
		set_state(EVADE) # We bumped into the player!
		var vel = body.get_last_velocity()
		
		var height = $MeshInstance.mesh.height
		# If the player is on top of the enemy, it's a curb stomp.
		if floor(body.translation.y) > floor(self.translation.y + height):
			var gravity = Globals.get_total_gravity_for(self)
			var damage = impact_to_damage(body, Vector3(vel.x, gravity.y, vel.z))
			adjust_health(-damage)

func noise_from(position, loudness):
	# If it was loud, it should be investigated.
	if loudness >= 1:
		Debug.print("Heard noise at " + str(position) + " (loudness=" + str(loudness) + ")")
		senses["hearing"].append(position)

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
	#Debug.print("PATROLING (" + str(self) + ")")
	target = get_parent().exit_door()
	chase(last_state, 20, true, true)

func search(last_state, delta):
	Debug.print("SEARCHING")

func attack(last_state, delta):
	Debug.print("ATTACKING (" + str(self) + ")")
	target = player
	chase(last_state)
	set_state(EVADE)

func defend(last_state, delta):
	Debug.print("DEFENDING")

func evade(last_state, delta):
	#Debug.print("EVADING")
	target = player
	chase(last_state, 0, false, true, -10, 10)

var chase_offset
var chase_path
var last_target_translation = null
func chase(last_state, backoff=null, rotated=false, meander=false, meander_min=null, meander_max=null):
	var need_new_path = false
	var should_move = true
	if backoff == null:
		backoff = backoff_distance
	if meander_min == null:
		meander_min = 0
	if meander_max == null:
		meander_max = 10
	
	var offset
	if meander:
		var vals = []
		for i in range(0, 3):
			vals.append(rand_range(meander_min, meander_max))
		offset = Vector3(vals[0], vals[1], vals[2])
	else:
		offset = Vector3(0, 0, 0)
	
	
	if target_translation == null:
		target_translation = target.translation
	
	var distance_check = map.get_path(translation, target_translation)
	if state != last_state or chase_path == null or last_target_translation == null:
		need_new_path = true
	elif distance_check.get_baked_length() > backoff:
		need_new_path = (chase_path.get_baked_length() - chase_offset) <= 2
	else:
		# We are at or closer than the backoff distance; no need to move.
		should_move = false
	
	if need_new_path:
		Debug.print("  UPDATING PATH")
		last_target_translation = target.translation
		var path_end = map.navigation.get_closest_point(target.translation + offset)
		chase_path = map.get_path(translation, path_end)
		chase_offset = 0
	
	if chase_path == null:
		return
	
	if should_move:
		print("MOB MOVED")
		print("  old = " + str(translation))
		translation = chase_path.interpolate_baked(chase_offset)
		chase_offset += 0.25
		print("  new = " + str(translation))
	
	#if rotated:
	#	rotate(Vector3(0, 1, 0), rand_range(85, 95))
	
	if see_player("left") or see_player("center") or see_player("right"):
		evade_cooldown_start()
		target = player
		set_state(EVADE)
	elif len(senses["hearing"]) > 0:
		target = null
		target_translation = senses["hearing"][0]
		senses["hearing"].remove(0)
		set_state(EVADE)


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