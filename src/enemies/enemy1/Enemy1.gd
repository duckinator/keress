extends RigidBody

enum { IDLE, SEARCH, ATTACK, EVADE }

const MAX_SPEED = 50
const MAX_HEALTH = 140
const MASS = 80

const BACKOFF = 16

var health

var navigation = null
var player = null

var state = IDLE

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

var last_target = null
var target = null setget set_target, get_target
func _ready():
	self.health = MAX_HEALTH
	self.mass = MASS
	self.mode = MODE_CHARACTER
	
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")

func set_target(new_target):
	last_target = target
	target = new_target

func get_target():
	return target

func _process(delta):
	# If no Navigation has been assigned, we can't move, so just return.
	if navigation == null:
		return
	
	# If no Player has been assigned, we can't do anything useful, so just return.
	if player == null:
		return
	
	match state:
		IDLE:
			idle(delta)
		SEARCH:
			search(delta)
		ATTACK:
			attack(delta)
		EVADE:
			evade(delta)

func distance_to_player():
	return translation.distance_to(player.translation)

func have_line_of_sight():
	# TODO: Add RayCasts and such to _actually_ determine line of sight.
	return distance_to_player() < 50

func check(trans):
	Console.log("MOB " + str(self) + " INSTRUCTED TO CHECK " + str(trans))
	target = trans
	state = SEARCH

func idle(delta):
	if have_line_of_sight():
		state = SEARCH
		target = player.translation

var search_path = null
var search_path_offset = 0
func search(delta):
	var offset = Vector3(rand_range(-BACKOFF, BACKOFF), 0, rand_range(-BACKOFF, BACKOFF))
	if search_path == null:
		search_path = Map.get_path_curve(translation, target + offset)
		search_path_offset = 0
	
	if search_path == null:
		return
		
	if translation.distance_to(target) <= BACKOFF:
		state = ATTACK
		search_path = null
		return
	
	translation = search_path.interpolate_baked(search_path_offset)
	search_path_offset += 0.5

var attack_path = null
var attack_path_offset = 0
var attack_path_timeout = null
func attack(delta):
	if attack_path == null:
		attack_path = Map.get_path_curve(translation, target)
	
	if attack_path == null or attack_path_timeout != null:
		return
	
	translation = attack_path.interpolate_baked(attack_path_offset)
	attack_path_offset += 0.5

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
	pass


func raycast_name(raycast):
	return RAYCAST_NAMES[raycast]

func found_player(raycast, player, position):
	senses[raycast_name(raycast)] = player

func found_nothing(raycast):
	senses[raycast_name(raycast)] = null

func found_object(raycast, object, position):
	senses[raycast_name(raycast)] = object

func heard_noise(trans, _sound, _loudness):
	if translation.distance_to(trans) < 50:
		Map.add_area_of_interest(self, trans)


func die():
	var scene = get_tree().current_scene
	if scene.has_method("mob_died"):
		scene.mob_died(self)

func cleanup():
	# This can be expanded by adding a death animation and such later.
	queue_free()

func adjust_health(value):
	Map.add_area_of_interest(self, translation)
	health = clamp(health + value, 0, MAX_HEALTH)
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
		if body.translation.y > translation.y:
			var vel = body.get_last_velocity()
			var damage = impact_to_damage(body, vel)
			adjust_health(-damage * 3)
			body.jump()
		#if state != ATTACK:
		#	body.adjust_health(-5)
		pass
	else:
		pass
		#set_state(EVADE) # We bumped into the player without seeing them!
	        
	var vel = body.get_last_velocity()
	var height = $MeshInstance.mesh.height
	# If the player is on top of the enemy, it's a curb stomp.
	if floor(body.translation.y) > floor(self.translation.y + height):
		#set_state(EVADE)
		var gravity = Game.get_total_gravity_for(self)
		var damage = impact_to_damage(body, Vector3(vel.x, gravity.y, vel.z))
		adjust_health(-damage)
