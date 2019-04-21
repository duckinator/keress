extends KinematicBody

const GRAVITY = -100
const MAX_SPEED = 80
const JUMP_SPEED = 50
const ACCEL = 7
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var MOUSE_SENSITIVITY = 0.2

var vel = Vector3(0, 0, 0)
var dir = Vector3(0, 0, 0)

const MAX_HEALTH = 100
var health = -1

var current_weapon = 0
var changing_weapon

var is_dead = false
var waiting_for_respawn = false

var animation_manager
var camera
var rotation_helper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	
	animation_manager = $Rotation_Helper/Model/Armature/AnimationPlayer
	#animation_manager.callback_function = funcref(self, "fire_bullet")
	
	adjust_health(MAX_HEALTH)

func _physics_process(delta):
	if not is_dead:
		process_input(delta)
		process_movement(delta)
		process_changing_weapons(delta)
		process_reloading(delta)
	process_ui(delta)
	process_respawn(delta)

func process_input(delta):
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
	if (is_on_floor() or is_on_wall()) and Input.is_action_just_pressed("movement_jump") :
		vel.y = JUMP_SPEED

	# Firing weapons
	#if Input.is_action_pressed("fire"):
	#	fire_weapon()

	# Reloading weapons
	#if Input.is_action_just_pressed("reload") or current_weapon.ammo_in_weapon <= 0:
	#	reload_weapon()

	# If needed, capture the cursor.
	# This applies both upon starting the game and when un-pausing.
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta * GRAVITY
	
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
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_changing_weapons(delta):
	pass

func process_reloading(delta):
	pass

func process_ui(delta):
	update_hud()

func process_respawn(delta):
	pass

func _input(event):
	if is_dead:
		if Input.is_key_pressed(KEY_SPACE):
			waiting_for_respawn = true
		return
	
	# Mouse movement.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		safe_rotate(event.relative)

	# Changing weapons.
	var weapon_change_number = current_weapon
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	#if Input.is_key_pressed(KEY_3):
	#	weapon_change_number = 2
	#if Input.is_key_pressed(KEY_4):
	#	weapon_change_number = 3

	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon_change_number -=1
	
	#weapon_change_number = clamp(weapon_change_number, 0, weapons.size() - 1)
	
	#if changing_weapon == false:
	#	if weapon_change_number != weapon_number:
	#		pass # Change weapons

func adjust_health(diff):
	health = clamp(health + diff, 0, MAX_HEALTH)
	update_hud()

func update_hud():
	$HUD/Panel_Left/Label_Health.text = str(health)
	$HUD/Panel_Left/Health_Bar.value = health
	# TODO: Handle weapon/ammo.


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