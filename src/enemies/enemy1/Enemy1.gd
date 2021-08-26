extends RigidBody

enum { IDLE, SEARCH, ATTACK, EVADE }

const MAX_SPEED = 50
const MAX_HEALTH = 140
const MASS = 80

const BACKOFF = 16

# How many times more damage is dealt the mob slams into a floor.
const FALL_DAMAGE_MULTIPLIER = MAX_HEALTH / 100.0

onready var health = MAX_HEALTH

var state = IDLE
var last_state = state

var map
var navigation
var player

onready var RAYCAST_NAMES = {
	#???: "left",
	$Front: "front",
	#???: "right",
	$Left: "left-side",
	$Right: "right-side",
}

var senses = {
	"left-side": null,
	"right-side": null,
	"front": null,
	"hearing": [],
}

var last_y = null

var last_velocity = Vector3(0, 0, 0)

var last_target = null
var target = null setget set_target, get_target

func _ready():
	Console.log("Enemy1._ready()")
	self.mass = MASS
	#self.mode = MODE_CHARACTER
	
	map = get_tree().current_scene
	navigation = map.get_node('Navigation')
	player = map.get_node('Player')
	
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	var err = connect("body_entered", self, "_process_body_entered")
	if err != OK:
		Console.log(err)
	Noise.add_listener(self, "heard_noise")
	
	map.mobs.append(self)

func get_last_velocity():
	return linear_velocity

func set_target(new_target):
	last_target = target
	target = new_target

func get_target():
	return target

func set_state(new_state):
	last_state = state
	state = new_state

func jump(assist=1):
	apply_central_impulse(Vector3.UP * (1000 * assist))

func _process(delta):
	# If no Navigation has been assigned, we can't move, so just return.
	if navigation == null:
		return
	
	# If no Player has been assigned, we can't do anything useful, so just return.
	if player == null:
		return
	
	if see_player() or near_player() and not (state == ATTACK or state == EVADE or state == SEARCH):
		target = player.translation
		set_state(SEARCH)
	
	match state:
		IDLE:
			idle(delta)
		SEARCH:
			search(delta)
		ATTACK:
			attack(delta)
		EVADE:
			evade(delta)
	last_state = state

func _physics_process(_delta):
	if last_y == null:
		last_y = translation.y

func distance_to_player():
	return translation.distance_to(player.translation)

func near_player():
	return distance_to_player() < 50

func see_player():
	for key in senses.keys():
		if key != "hearing" and senses[key] == player:
			return true
	return false

func investigate(trans):
	#Console.log("MOB " + str(self) + " INSTRUCTED TO CHECK " + str(trans))
	target = trans
	set_state(SEARCH)

func idle(delta):
	pass

var chase_path = null
var chase_path_offset = 0
func chase(delta, backoff):
	if target == null:
		return
	
	var offset = Vector3(rand_range(-backoff, backoff), 0, rand_range(-backoff, backoff))

	if chase_path == null or last_state != state:
		#chase_path = Map.get_path_curve(translation, target + offset)
		#chase_path_offset = 0
		pass
	
	if chase_path == null:
		set_state(IDLE)
		return
	
	var pos = chase_path.interpolate_baked(chase_path_offset)
	var diff = pos - translation
	# HACK: Why is this diff4 nonsense needed? :(
	var diff4 = diff * 4
	diff4.y = diff.y
	apply_central_impulse(diff4)
	last_velocity = diff4
	chase_path_offset += 0.5

func search(delta):
	chase(delta, BACKOFF - 2)
	if translation.distance_to(target) <= BACKOFF:
		set_state(ATTACK)
		return

var attack_path_timeout = null
func attack(delta):
	if attack_path_timeout != null:
		set_state(EVADE)
		return
	if not see_player() and not near_player():
		set_state(IDLE)
		return
	
	chase(delta, 0)
	if distance_to_player() < 4:
		Console.log("PEW PEW")
		player.adjust_health(-5)

const ATTACK_TIMEOUT = 0.5
func _start_attack_path_timeout():
	if attack_path_timeout == null:
		attack_path_timeout = Timer.new()
		attack_path_timeout.wait_time = rand_range(ATTACK_TIMEOUT, ATTACK_TIMEOUT * 2)
		attack_path_timeout.one_shot = true
		attack_path_timeout.connect("timeout", self, "_end_attack_path_timeout")
		add_child(attack_path_timeout)
		attack_path_timeout.start()

func _end_attack_path_timeout():
	remove_child(attack_path_timeout)
	attack_path_timeout.stop()
	attack_path_timeout.queue_free()
	attack_path_timeout = null


func evade(delta):
	#Console.log(str(self) + " EVADE")
	chase(delta, 16)


func raycast_name(raycast):
	return RAYCAST_NAMES[raycast]

func found_player(raycast, player, _position):
	senses[raycast_name(raycast)] = player

func found_nothing(raycast):
	senses[raycast_name(raycast)] = null

func found_object(raycast, object, _position):
	senses[raycast_name(raycast)] = object

func heard_noise(trans, _sound, _loudness):
	#if translation.distance_to(trans) < 50:
	#	AreasOfInterest.add_aoi(trans)
	pass


func die():
	var scene = get_tree().current_scene
	if scene.has_method("mob_died"):
		scene.mob_died(self)

func cleanup():
	# This can be expanded by adding a death animation and such later.
	queue_free()

func adjust_health(value):
	AreasOfInterest.add_aoi(translation)
	health = clamp(round(health + value), 0, MAX_HEALTH)
	Console.debug(str(self) + ".health = " + str(health))
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
	return ceil(force / 400)

func impact_to_damage(collider, collider_vel):
	var force = impact_to_force(collider, collider_vel)
	return force_to_damage(force)


func _process_body_entered(body):
	# Fall damage.
	if body is StaticBody:
		if last_y == null:
			return
		var diff = abs(translation.y - last_y)
		if diff > 1:
			adjust_health(-diff * FALL_DAMAGE_MULTIPLIER)
		last_y = translation.y
		return
	
	if not body.has_method("get_last_velocity"):
		return
	
	#var height = $MeshInstance.mesh.height
	if floor(body.translation.y) > floor(translation.y):
		# Curb stomps.
		var vel = body.get_last_velocity()
		var damage = impact_to_damage(body, vel) * 10
		adjust_health(-damage)
	else:
		# Less dramatic impacts.
		var vel = body.get_last_velocity()
		var damage = impact_to_damage(body, vel) / 10
		adjust_health(-damage)
	
	if body.has_method("jump"):
		body.jump()
	
	var is_player = body is KinematicBody and body.name == "Player"
	var is_enemy = body is RigidBody and body.name.begins_with("Enemy")
	if is_enemy or is_player:
		target = body.translation
	set_state(EVADE)
