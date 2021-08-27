extends Spatial

# Sound name and loudness for primary action.
const SOUND_PRIMARY = "weapon/revolver_fire"
const LOUDNESS_PRIMARY = 15

# Sound name and loudness for secondary action.
const SOUND_SECONDARY = null
const LOUDNESS_SECONDARY = 15

# The damage a single shot deals.
const DAMAGE = 40

# The maximum amount the camera can rotate up (positive) or down (negative)
# after the primary or secondary actions.
const JOSTLE_PRIMARY = 0.25
const JOSTLE_SECONDARY = 0

# The shortest duration possible between firing.
const PRIMARY_TIMEOUT = 0.4

const MAX_AMMO = 200

var ammo = MAX_AMMO

onready var player = get_tree().current_scene.get_node('Player')
onready var raycast = get_tree().current_scene.get_node('Player/RotationHelper/TargetRayCast')
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

func primary():
	if  ammo > 0 and primary_timeout != null:
		return
	
	primary_timeout_start()
	Noise.emit(player.translation, SOUND_PRIMARY, LOUDNESS_PRIMARY)
	raycast.force_raycast_update()
	ammo -= 1
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("adjust_health"):
			collider.adjust_health(-DAMAGE)
			if collider is RigidBody:
				var impulse = (to_global($Spatial/SpotLight.translation) - to_global(raycast.translation))
				var impulse_y = impulse.y
				impulse *= 800
				impulse.y = 4000
				if impulse_y < -2:
					impulse.y = -impulse.y
				collider.apply_impulse(Vector3(0, 3, 0), impulse)

func secondary():
	Console.log("TODO: Pistol secondary")
	# Noise.emit(get_parent().translation, SOUND_PRIMARY, LOUDNESS_PRIMARY)
