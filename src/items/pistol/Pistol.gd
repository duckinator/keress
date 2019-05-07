extends StaticBody

const MAX_AMMO = 200
const MAX_IN_WEAPON = 30
var ammo = MAX_AMMO - MAX_IN_WEAPON
var in_weapon = MAX_IN_WEAPON

func _ready():
	set_meta("is_item", true)
	add_collision_exception_with(Game.get_player())

func primary():
	Console.log("TODO: Pistol primary")

func secondary():
	Console.log("TODO: Pistol secondary")

func reload():
	var diff = clamp(MAX_IN_WEAPON - in_weapon, 0, ammo)
	ammo -= diff
	in_weapon = diff

func needs_reload():
	return in_weapon < (MAX_IN_WEAPON / 4)