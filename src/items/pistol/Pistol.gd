extends StaticBody

const MAX_AMMO = 200

const PRIMARY_TIMEOUT = 0.05

var ammo = MAX_AMMO

onready var raycast = $RayCast
var primary_timeout = null

func _ready():
	set_meta("is_item", true)
	add_collision_exception_with(Game.get_player())

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
	if ammo > 0 and primary_timeout != null:
		return
	
	primary_timeout_start()
	ammo = clamp(ammo - 1, 0, MAX_AMMO)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("adjust_health"):
			collider.adjust_health(-10)

func secondary():
	Console.log("TODO: Pistol secondary")
