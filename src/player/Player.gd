extends KinematicBody

var fall_damage_enabled = true

const MASS = 100

var gravity
const MAX_SPEED = 80
const JUMP_SPEED = 50
const ACCEL = 7
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

const SOUND_CLIMB = "player/climb"
const SOUND_FALL_DAMAGE = "player/fall"

const LOUDNESS_CLIMB = 1
const LOUDNESS_FALL_DAMAGE = 3

var MOUSE_SENSITIVITY = 0.2

var vel = Vector3(0, 0, 0)
var dir = Vector3(0, 0, 0)

const MAX_HEALTH = 100
var health = 0

const INVENTORY_MAX_SIZE = 3
var inventory = []
var current_item = 0
var last_item = 0
var changing_item = false

var is_dead = false
var waiting_for_respawn = false

var camera
var rotation_helper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper

	inventory.append($RotationHelper/Pistol)
	#inventory.append($RotationHelper/Rifle)
	#inventory.append($RotationHelper/Shotgun)

	adjust_health(MAX_HEALTH)

func _physics_process(delta):
	if not gravity:
		gravity = Game.get_total_gravity_for($DummyRigidBody)
		$DummyRigidBody.visible = false
	
	if not is_dead:
		process_input(delta)
		process_input_inventory(delta)
		process_movement(delta)
		process_changing_item(delta)
		process_reloading(delta)
	process_ui(delta)
	process_respawn(delta)

func get_last_velocity():
	return vel

func adjust_health(diff):
	health = clamp(health + diff, 0, MAX_HEALTH)
	return health

func reload_weapon():
	pass

func update_hud():
	$HUD/Panel_Left/Label_Health.text = str(health)
	$HUD/Panel_Left/Health_Bar.value = health
	# TODO: Handle weapon/ammo.

func emit_sound(trans, sound, loudness):
	get_tree().current_scene.player_noise(trans, sound, loudness)

func safe_rotate(vec):
	rotation_helper.rotate_x(deg2rad(vec.y * MOUSE_SENSITIVITY * -1))
	self.rotate_y(deg2rad(vec.x * MOUSE_SENSITIVITY * -1))
	# Set x/z to zero to avoid very strange camera stuff.
	self.rotation_degrees.x = 0
	self.rotation_degrees.z = 0
	
	var camera_rot = rotation_helper.rotation_degrees
	# FIXME: -70,70 is pretty arbitrary. It's worth playing with.
	camera_rot.x = clamp(camera_rot.x, -70, 70)
	# Set y/z to zero to avoid very strange camera stuff.
	camera_rot.y = 0
	camera_rot.z = 0
	rotation_helper.rotation_degrees = camera_rot

# Various _process_* functions:

func process_input(_delta):
	if Console.visible:
		return
	
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
	# Jumping
	# TODO: Add debounce timer.
	if (is_on_floor() or is_on_wall()) and Input.is_action_pressed("movement_jump"):
		vel.y = JUMP_SPEED

func process_input_inventory(_delta):
	if len(inventory) == 0:
		return
	
	current_item = clamp(current_item, 0, len(inventory) - 1)
	var item = inventory[current_item]
	if item == null:
		return

	# Firing weapons
	if Input.is_action_pressed("action_primary"):
		Console.log("TODO: Primary action.")
		item.primary()
		#fire_bullet(Vector3(100, 0, 0))
	if Input.is_action_pressed("action_secondary"):
		Console.log("TODO: secondary action")
		item.secondary()

	# Reloading weapons
	var needs_reload = item.has_method("needs_reloaded") and item.needs_reload()
	if Input.is_action_just_pressed("action_reload") or needs_reload:
		item.reload()

func process_movement(delta):
	dir = dir.normalized()
	
	vel += Vector3(delta * gravity.x, delta * gravity.y, delta * gravity.z)
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	var old_vel = vel
	vel = move_and_slide(vel, Vector3(0, 1, 0), false, 4, deg2rad(MAX_SLOPE_ANGLE))

	process_fall_damage(old_vel, vel)

func process_changing_item(_delta):
	pass

func process_reloading(_delta):
	pass

func process_ui(_delta):
	update_hud()

func process_respawn(_delta):
	pass

func process_fall_damage(old_vel, vel):
	# If we're going down faster than we can jump up, take damage.
	if fall_damage_enabled and old_vel.y < -JUMP_SPEED and vel.y >= -1:
		var tmp = int(ceil(old_vel.y / 10))
		tmp -= tmp % 5
		if tmp <= -5:
			Console.log("Player took fall damage: " + str(tmp))
			adjust_health(tmp)
			emit_sound(translation, SOUND_FALL_DAMAGE, LOUDNESS_FALL_DAMAGE)

func _input(event):
	# TODO: Determine why there's no KEY_BACKTICK or similar?
	if Input.is_key_pressed(96):
		Console.toggle()
	
	if is_dead:
		if Input.is_key_pressed(KEY_SPACE):
			waiting_for_respawn = true
		return
	
	# Mouse movement.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		safe_rotate(event.relative)

	# No point doing all of this with an empty inventory.
	if len(inventory) == 0:
		return

	# Changing inventory item.
	var changing_item_number = current_item
	if Input.is_action_just_pressed("quick_switch_item"):
		changing_item_number = last_item
	if Input.is_key_pressed(KEY_1):
		changing_item_number = 0
	if Input.is_key_pressed(KEY_2):
		changing_item_number = 1
	if Input.is_key_pressed(KEY_3):
		changing_item_number = 2
	if Input.is_key_pressed(KEY_4):
		changing_item_number = 3

	if Input.is_action_just_pressed("shift_item_positive"):
		changing_item_number += 1
	if Input.is_action_just_pressed("shift_item_negative"):
		changing_item_number -=1
	
	changing_item_number = clamp(changing_item_number, 0, len(inventory) - 1)
	
	if changing_item == false:
		if changing_item_number != current_item:
			Console.log("TODO: Switch to item #" + str(changing_item_number + 1))
			pass # Change weapons