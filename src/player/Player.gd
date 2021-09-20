extends KinematicBody

var weapon = Gun.WEAPON_DEAGLE
var ammo = Gun.MAX_AMMO

onready var weapon_animation_players = {
	Gun.WEAPON_DEAGLE: [$RotationHelper/DEagle/DEagle/DEagleSlide/AnimationPlayer],
}

var fall_damage_enabled = true

const FALL_MULTIPLIER = 1.0
const LOW_JUMP_MULTIPLIER = 1.5


const MASS = 100

var gravity
const MAX_SPEED = 30
const JUMP_SPEED = 25
const ACCEL = 4
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

const SOUND_CLIMB = "player/climb"
const SOUND_FALL_DAMAGE = "player/fall"

const LOUDNESS_CLIMB = 1
const LOUDNESS_FALL_DAMAGE = 3

var MOUSE_SENSITIVITY = 0
var JOYPAD_SENSITIVITY = 0

var vel = Vector3(0, 0, 0)
var dir = Vector3(0, 0, 0)

const MAX_HEALTH = 100
var health = 0

var is_dead = false
var waiting_for_respawn = false

var camera
var rotation_helper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper

	reload_player_settings()
	var err = Game.connect("resume", self, "reload_player_settings")
	if err != OK:
		Console.error("Game.connect('resume') failed", err)

	adjust_health(MAX_HEALTH)
	camera.set_current(true)

# Load settings that need to be set before playing, or may change while the
# game is paused.
func reload_player_settings():
	camera.fov = Settings.fetch("field_of_view")
	MOUSE_SENSITIVITY = float(Settings.fetch("mouse_sensitivity")) / 100
	JOYPAD_SENSITIVITY = Settings.fetch("joypad_sensitivity")

func _process(_delta):
	var horiz = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vert = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	horiz *= JOYPAD_SENSITIVITY
	vert *= JOYPAD_SENSITIVITY
	safe_rotate(Vector2(horiz, vert))

func _physics_process(delta):
	if not gravity:
		gravity = _get_total_gravity_for($DummyRigidBody)
		$DummyRigidBody.visible = false
	
	if not is_dead:
		process_input(delta)
		process_movement(delta)
	process_ui(delta)
	process_respawn(delta)

func _get_total_gravity_for(body):
	var state = PhysicsServer.body_get_direct_state(body.get_rid())
	return state.get_total_gravity()

func get_last_velocity():
	return vel

func adjust_health(diff):
	health = clamp(health + diff, 0, MAX_HEALTH)
	return health

func update_hud():
	$HUD/Panel_Left/Label_Health.text = str(health)
	$HUD/Panel_Left/Health_Bar.value = health
	
	$HUD/Panel_Left/Label_Ammo.text = str(ammo)
	$HUD/Panel_Left/Ammo_Bar.value = ammo
	$HUD/Panel_Left/Ammo_Bar.max_value = Gun.MAX_AMMO

func emit_sound(trans, sound, loudness):
	Noise.emit(trans.round(), sound, loudness)

func safe_rotate(vec):
	rotation_helper.rotate_x(deg2rad(vec.y * MOUSE_SENSITIVITY * -1))
	self.rotate_y(deg2rad(vec.x * MOUSE_SENSITIVITY * -1))
	# Set x/z to zero to avoid very strange camera stuff.
	self.rotation_degrees.x = 0
	self.rotation_degrees.z = 0
	
	var camera_rot = rotation_helper.rotation_degrees
	# FIXME: This clamp() is pretty arbitrary. It's worth playing with.
	#        -89,89 is one degree before straight down to one degree before straight up.
	#        Anything beyond this would allow the player to see behind them, which is a bit silly.
	camera_rot.x = clamp(camera_rot.x, -80, 89)
	# Set y/z to zero to avoid very strange camera stuff.
	camera_rot.y = 0
	camera_rot.z = 0
	rotation_helper.rotation_degrees = camera_rot

func jostle(amplitude):
	var y = rand_range(0, -amplitude)
	safe_rotate(Vector3(0, y, 0))

func jump(assist=1):
	vel.y = JUMP_SPEED * assist

# Various _process_* functions:

func process_input(_delta):
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += Input.get_action_strength("movement_forward")
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= Input.get_action_strength("movement_backward")
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= Input.get_action_strength("movement_left")
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += Input.get_action_strength("movement_right")
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
	# Jumping
	if (is_on_floor() or is_on_wall()) and Input.is_action_just_pressed("movement_jump"):
		vel.y = JUMP_SPEED
	
	# Firing weapon
	if Input.is_action_pressed("action_primary"):
		Gun.primary(self, $RotationHelper/TargetRayCast)
	if Input.is_action_pressed("action_secondary"):
		Gun.secondary(self, $RotationHelper/TargetRayCast)

func process_movement(delta):
	dir = dir.normalized()
	
	vel += Vector3(delta * gravity.x, delta * gravity.y, delta * gravity.z)
	
	if vel.y < 0:
		vel += Vector3.UP * gravity.y * (FALL_MULTIPLIER - 1) * delta
	elif (vel.y > 0) and not Input.is_action_pressed("movement_jump"):
		vel += Vector3.UP * gravity.y * (LOW_JUMP_MULTIPLIER - 1) * delta
	
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

func process_ui(_delta):
	update_hud()

func process_respawn(_delta):
	pass

func process_fall_damage(old_vel, cur_vel):
	# If we're going down faster than we can jump up, take damage.
	if old_vel.y < -JUMP_SPEED and cur_vel.y >= -1:
		if  fall_damage_enabled:
			var tmp = int(ceil(old_vel.y / 10))
			tmp -= tmp % 5
			if tmp <= -5:
				Console.log("Player took fall damage: " + str(tmp))
				adjust_health(tmp)
		emit_sound(translation, SOUND_FALL_DAMAGE, LOUDNESS_FALL_DAMAGE)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Game.pause()
		return

	if is_dead:
		if Input.is_key_pressed(KEY_SPACE):
			waiting_for_respawn = true
		return
	
	# Mouse movement.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		safe_rotate(event.relative)
