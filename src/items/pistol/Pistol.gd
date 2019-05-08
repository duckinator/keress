extends StaticBody

const MAX_AMMO = 200
const MAX_IN_WEAPON = 30
var ammo = MAX_AMMO - MAX_IN_WEAPON
var in_weapon = MAX_IN_WEAPON

onready var raycast = $RayCast

func _ready():
	set_meta("is_item", true)
	add_collision_exception_with(Game.get_player())

func primary():
	ammo = clamp(ammo - 1, 0, MAX_AMMO)
	in_weapon = clamp(in_weapon - 1, 0, MAX_IN_WEAPON)
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("adjust_health"):
			collider.adjust_health(-10)

func secondary():
	Console.log("TODO: Pistol secondary")

func reload():
	var diff = clamp(MAX_IN_WEAPON - in_weapon, 0, ammo)
	ammo -= diff
	in_weapon = diff

func needs_reload():
	return in_weapon < (MAX_IN_WEAPON / 4)

func _needs_ammo():
	return ammo < (MAX_AMMO / 10)

func needs_attention():
	return needs_reload() or _needs_ammo()