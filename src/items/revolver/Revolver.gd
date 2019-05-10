extends Spatial

const DAMAGE = 70

const PRIMARY_TIMEOUT = 0.6

const MAX_IN_WEAPON = 6
const MAX_AMMO = MAX_IN_WEAPON

var ammo = MAX_AMMO
var in_weapon = MAX_AMMO

onready var laser = $Spatial/Spotlight
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

onready var reset_vec = self.translation
onready var reset_rot = self.rotation
var start_vec = Vector3(0, 0, 0)
var end_vec = Vector3(kick_rot, kick_trans_y, kick_trans_z)

func reset_position(object, key):
	translation = reset_vec
	rotation = reset_rot

func gun_kick_undo(object, key):
	Console.log("undo???")
	var tween = $KickTween
	tween.reset_all()
	tween.disconnect("tween_completed", self, "gun_kick_undo")
	tween.connect("tween_completed", self, "reset_position")
	tween.interpolate_method(self, "kick_negative_by", start_vec, end_vec, kick_part_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func gun_kick():
	var tween = $KickTween
	tween.reset_all()
	tween.disconnect("tween_completed", self, "gun_kick_undo")
	tween.disconnect("tween_completed", self, "reset_position")
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