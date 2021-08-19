extends Spatial

# Sound name and loudness for primary action.
const SOUND_PRIMARY = "weapon/revolver_fire"
const LOUDNESS_PRIMARY = 15

# Sound name and loudness for secondary action.
const SOUND_SECONDARY = null
const LOUDNESS_SECONDARY = 15

# The damage a single shot deals.
const DAMAGE = 70

# The maximum amount the camera can rotate up (positive) or down (negative)
# after the primary or secondary actions.
const JOSTLE_PRIMARY = 0.25
const JOSTLE_SECONDARY = 0

# If the timeout and recoil duration mismatch, it makes the weapon feel
# more "sloppy" -- the more quickly you fire it, the less accurate it gets.

# The shortest duration possible between firing.
const PRIMARY_TIMEOUT = 0.4
# The time it takes to finish recoiling.
# TODO: Make PRIMARY_RECOIL_DURATION actually used.
#const PRIMARY_RECOIL_DURATION = 0.6

const MAX_IN_WEAPON = 6
const MAX_AMMO = MAX_IN_WEAPON

var ammo = MAX_AMMO
var in_weapon = MAX_AMMO

onready var laser = $Spatial/SpotLight
onready var raycast = $Spatial/RayCast
var primary_timeout = null

func _ready():
	set_meta("is_item", true)

func primary_timeout_start():
	primary_timeout = Timer.new()
	primary_timeout.wait_time = PRIMARY_TIMEOUT
	primary_timeout.one_shot = true
	primary_timeout.connect("timeout", self, "primary_timeout_reset")
	add_child(primary_timeout)
	primary_timeout.start()

func primary_timeout_reset():
	primary_timeout.stop()
	primary_timeout = null

func kick_rotate(amount):
	rotate_x(deg2rad(amount))

func kick_translate_y(amount):
	translate(Vector3(0, amount, 0))

func kick_translate_z(amount):
	translate(Vector3(0, 0, amount))

func kick_negative_by(vec):
	kick_rotate(-vec.x)
	kick_translate_y(-vec.y)
	kick_translate_z(-vec.z)

func kick_by(vec):
	kick_rotate(vec.x)
	kick_translate_y(vec.y)
	kick_translate_z(vec.z)

var kick_part_length = 0.15
var kick_rot = 2.0
var kick_trans_y = 0.2
var kick_trans_z = 0.3

onready var tween = $KickTween

onready var reset_vec = self.translation
onready var reset_rot = self.rotation
var start_vec = Vector3(0, 0, 0)
var end_vec = Vector3(kick_rot, kick_trans_y, kick_trans_z)

func _disconnect_tween_signals():
	if tween.is_connected("tween_completed", self, "gun_kick_undo"):
		tween.disconnect("tween_completed", self, "gun_kick_undo")

	if tween.is_connected("tween_completed", self, "reset_position"):
		tween.disconnect("tween_completed", self, "reset_position")

func reset_position(object, key):
	_disconnect_tween_signals()
	translation = reset_vec
	rotation = reset_rot

func gun_kick_undo(object, key):
	tween.reset_all()
	_disconnect_tween_signals()
	tween.connect("tween_completed", self, "reset_position")
	tween.interpolate_method(self, "kick_negative_by", start_vec, end_vec, kick_part_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func gun_kick():
	tween.reset_all()
	
	_disconnect_tween_signals()
	
	tween.connect("tween_completed", self, "gun_kick_undo")
	tween.interpolate_method(self, "kick_by", start_vec, end_vec, kick_part_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func cylinder_revolve():
	# Fuck everything, I'm just leaving this as a TODO.
	pass

func primary():
	if primary_timeout != null:
		return
	
	primary_timeout_start()
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("adjust_health"):
			collider.adjust_health(-DAMAGE)
			if collider is RigidBody:
				var impulse = (to_global($Spatial/SpotLight.translation) - to_global($Spatial/RayCast.translation))
				var impulse_y = impulse.y
				impulse *= 800
				impulse.y = 4000
				if impulse_y < -2:
					impulse.y = -impulse.y
				collider.apply_impulse(Vector3(0, 3, 0), impulse)
	gun_kick()
	cylinder_revolve()

func secondary():
	Console.log("TODO: Pistol secondary")

func reload():
	# No need to reload these.
	pass

func needs_reload():
	return false

func _needs_ammo():
	return ammo < MAX_AMMO

func needs_attention():
	return needs_reload() or _needs_ammo()
