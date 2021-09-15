extends RigidBody

enum { IDLE, SEARCH, EVADE }
const STATE_STRS = {IDLE: "IDLE", SEARCH: "SEARCH", EVADE: "EVADE"}

const MAX_SPEED = 50
const MAX_HEALTH = 140
const MASS = 80

const BACKOFF = 5

# How many times more damage is dealt the mob slams into a floor.
const FALL_DAMAGE_MULTIPLIER = MAX_HEALTH / 100.0

onready var health = MAX_HEALTH

var state = IDLE
var last_state = state

var map
var player

onready var RAYCAST_NAMES = {
	$Front: "front",
	$FrontUpper: "front-upper",
	$Rear: "rear",
	$Left: "left",
	$Right: "right",
	$LeftSide: "left-side",
	$RightSide: "right-side",
}

var senses = {
	"left-side": null,
	"right-side": null,
	"left": null,
	"right": null,
	"front": null,
	"front-upper": null,
	"rear": null,
	"hearing": [],
}

var last_y = null

var last_velocity = Vector3(0, 0, 0)

var last_target = null
var target = null setget set_target, get_target

func _ready():
	self.mass = MASS
	self.mode = MODE_CHARACTER
	
	$Viewport/VBoxContainer/Health.max_value = MAX_HEALTH
	update_label()
	
	map = get_tree().current_scene
	player = map.get_node('Player')
	
	#set_contact_monitor(true)
	#set_max_contacts_reported(5)
	#var err = connect("body_entered", self, "_process_body_entered")
	#if err != OK:
	#	Console.log(err)
	Noise.add_listener(self, "heard_noise")
	
	add_to_group("mobs")

func get_last_velocity():
	return last_velocity

func set_target(new_target):
	last_target = target
	target = new_target

func get_target():
	return target

onready var label = $Viewport/VBoxContainer/Label
func update_label():
	label.text = self.name + "(" + STATE_STRS[state] + ")"
	$Sprite3D.set_texture($Viewport.get_texture())

func set_state(new_state):
	last_state = state
	state = new_state
	update_label()
	
	if state == EVADE and state != last_state:
		reset_evade()

func jump(assist=1):
	$Below.force_raycast_update()
	if $Below.is_colliding():
		apply_central_impulse(Vector3.UP * (1000 * assist))

const BELOW_WORLD_DAMAGE = MAX_HEALTH / 10

var current = 0.0
func _process(delta):
	$Sprite3D.visible = Debug.mob_debug_enabled
	
	current += delta
	if current < 0.5:
		return
	
	if translation.y < -5:
		Console.log(name + " taking " + str(BELOW_WORLD_DAMAGE) + " damage from being below the world. :(")
		adjust_health(-BELOW_WORLD_DAMAGE)
	
	if see_player() and near_player():
		target = player.translation
		if state != EVADE:
			set_state(SEARCH)
	
	if target != null and target.y < 0:
		target.y = 0
	

	match state:
		IDLE:
			idle(delta)
		SEARCH:
			search(delta)
		EVADE:
			evade(delta)
	last_state = state

func _physics_process(_delta):
	if last_y == null:
		last_y = translation.y

func distance_to_player():
	return translation.distance_to(player.translation)

func near_player():
	if player == null:
		return false
	return distance_to_player() < 20

func uncomfortably_close_to_player():
	if player == null:
		return false
	return distance_to_player() < 2

func see_player():
	if player == null:
		return false
	
	for key in senses.keys():
		if key != "hearing" and senses[key] == player:
			return true
	return false

func investigate(trans):
	Console.log("MOB " + str(self) + " INSTRUCTED TO CHECK " + str(trans))
	if not see_player():
		intermediate_target = null
		target = trans
		set_state(SEARCH)

func idle(_delta):
	pass

var intermediate_target = null
var look_delta = 0.0
func chase(delta, backoff, offset=null):
	if target == null:
		return
	
	if offset == null:
		offset = Vector3(rand_range(-backoff, backoff), 0, rand_range(-backoff, backoff))

	Console.log("target = " + str(target) + "; intermediate_target = " + str(intermediate_target))
	var cur_target = target + offset
	Console.log(STATE_STRS[state] + "; " + str(cur_target))
	
	if look_delta > 1:
		look_delta = 0
		var look_target = cur_target
		look_target.y = 0.5
		look_at(look_target, Vector3(0, 1, 0))
	else:
		look_delta += delta

	var velocity = translation.direction_to(cur_target) * 75
	#Console.log(STATE_STRS[state] + "/chase(" + str(delta) + ", " + str(backoff) + "); velocity=" + str(velocity) + "; offset=" + str(offset))
	apply_central_impulse(velocity)
	last_velocity = velocity
	
	if senses["front"]:
		if not senses["left"]:
			Console.log("something to my front, but not my left")
			#Console.log("move left (front.collision=" + str($Front.get_collision_point()) + "; left.trans=" + str(to_global($Left.translation)) + ")")
			var left = to_global(Vector3(-1, 0, 0))
			intermediate_target = translation + to_global($Left.translation)
		elif senses["right"]:
			Console.log("something to my front, but not my right")
			intermediate_target = translation + to_global($Right.translation)
		else:
			Console.log("something to my front, left, AND right?")
	if intermediate_target:
		intermediate_target.y = 0
	
	if distance_to_player() < 4 and see_player():
		var new_target = player.translation
		new_target.x += pow(-1, randi() % 2) * 6
		new_target.z += pow(-1, randi() % 2) * 6
		Console.log("new target: " + str(new_target))
		target = new_target
	
	if uncomfortably_close_to_player() and see_player():
		# If they are on top of us, then they shouldn't take damage.
		var diff = player.translation.y - translation.y
		if diff < 1:
			Console.log("BAM")
			player.adjust_health(-5)

func search(delta):
	chase(delta, 0)


const DIRECTION_CHANGE_PERIOD = 3.0
var direction_change_current = 0.0
var direction = 1
const EVADE_PERIOD = 0.5 # 0.5s between each movement.
var evade_current = 0.0
var evade_offset = Vector3(0, 0, 0)
var evade_angle = 0
func reset_evade():
	direction_change_current = 0.0
	direction = 1
	evade_current = 0.0
	evade_offset = Vector3(0, 0, 0)
	evade_angle = 0

func evade(delta):
	if direction_change_current < DIRECTION_CHANGE_PERIOD:
		direction_change_current += delta
	else:
		direction_change_current = 0
		direction *= -1
	
	if evade_current < EVADE_PERIOD:
		evade_current += delta
		evade_angle += rand_range(5, 15) * direction # degrees to rotate by
		if evade_angle >= 360:
			evade_angle -= 360
	else:
		var radius = 8 # Stay 4m away.
	
		var evade_radians = evade_angle * 0.0174532925
	
		var x = radius * cos(evade_radians)
		var z = radius * sin(evade_radians)
		
		evade_offset = Vector3(x, 0, z)
		Console.log("Applying offset: " + str(evade_offset))
		evade_current = 0
	
	chase(delta, BACKOFF, evade_offset)


func raycast_name(raycast):
	return RAYCAST_NAMES[raycast]

func found_player(raycast, player_obj, _position):
	senses[raycast_name(raycast)] = player_obj

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
	cleanup()

func cleanup():
	# This can be expanded by adding a death animation and such later.
	queue_free()

func adjust_health(value):
	health = clamp(round(health + value), 0, MAX_HEALTH)
	$Viewport/VBoxContainer/Health.value = health
	if health <= 0:
		die()





#func vel_to_speed(vel):
#	var x = abs(vel.x)
#	var y = abs(vel.y)
#	var z = abs(vel.z)
#	return sqrt((x * x) + (y * y) + (z * z))
#
#func impact_to_force(collider, collider_vel):
#	var speed = vel_to_speed(collider_vel)
#	return collider.MASS * speed
#
#func force_to_damage(force):
#	return ceil(force / 400)
#
#func impact_to_damage(collider, collider_vel):
#	var force = impact_to_force(collider, collider_vel)
#	return force_to_damage(force)
#
#
#var last_body = null
#func _process_body_entered(body):
#	# Fall damage.
#	if body is StaticBody:
#		if last_y == null:
#			return
#		var diff = abs(translation.y - last_y)
#		if diff > 1:
#			adjust_health(-diff * FALL_DAMAGE_MULTIPLIER)
#		last_y = translation.y
#		return
#
#	if not body.has_method("get_last_velocity"):
#		return
#
#	#var height = $MeshInstance.mesh.height
#	if floor(body.translation.y) > floor(translation.y):
#		# Curb stomps.
#		var vel = body.get_last_velocity()
#		var damage = impact_to_damage(body, vel) * 10
#		adjust_health(-damage)
#	else:
#		# Less dramatic impacts.
#		var vel = body.get_last_velocity()
#		var damage = impact_to_damage(body, vel) / 10
#		adjust_health(-damage)
#
#	var is_player = body is KinematicBody and body.name == "Player"
#	var is_enemy = body is RigidBody and body.name.begins_with("Enemy")
#	if is_enemy or is_player:
#		target = body.translation
#
#		# If they are on top of us, then they shouldn't take damage.
#		var diff = body.translation.y - translation.y
#		if diff < 1:
#			Console.log("BAM")
#			body.adjust_health(-5)
#
#	if is_player:
#		var force = get_last_velocity()
#	#	Console.log("force = " + str(force))
#		jump()
#
#	if body.has_method("jump") and not is_player:
#		body.jump()
#	set_state(EVADE)
#	last_body = body
