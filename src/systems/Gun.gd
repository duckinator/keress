extends Node

const MAX_AMMO = 200

const WEAPON_DEAGLE = "DEAGLE"
const DEAGLE = {
	"primary": {
		"sound": "pistol_fire",
		"loudness": 15,
		"damage": 40,
		"timeout": 0.4,
	},
	"secondary": {
		"sound": null,
		"loudness": 15,
		"damage": 0,
		"timeout": 0.4,
	}
}

const WEAPONS = {
	WEAPON_DEAGLE: DEAGLE,
}


var PRIMARY_TIMEOUTS = {}
var SECONDARY_TIMEOUTS = {}


func _ready():
	var err = MapManager.connect("load_map", self, "clear_timeouts")
	Console.error_unless_ok("MapManager.connect('load_map') failed", err)

func primary(source, raycast):	
	if source.ammo == 0 or (source in PRIMARY_TIMEOUTS and PRIMARY_TIMEOUTS[source] != null):
		return
	
	var animation_player = source.weapon_animation_players[source.weapon]["primary_fire"]
	
	# If it's still playing the fire animation, wait.
	if animation_player.is_playing():
		return
	
	#animation_player.play("Fire")
	animation_player.play("DEagle.SlideAction")
	
	var weapon_data = WEAPONS[source.weapon]["primary"]
	Noise.emit(source.translation, weapon_data["sound"], weapon_data["loudness"])
	raycast.force_raycast_update()
	source.ammo -= 1
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("adjust_health"):
			collider.adjust_health(-weapon_data["damage"])
			if collider is RigidBody:
				#var impulse = (to_global($Spatial/SpotLight.translation) - to_global(raycast.translation))
				#var impulse_y = impulse.y
				#impulse *= 800
				#impulse.y = 4000
				#if impulse_y < -2:
				#	impulse.y = -impulse.y
				#collider.apply_impulse(Vector3(0, 3, 0), impulse)
				pass

func secondary(source, raycast):
	Console.log("TODO: " + str(source.weapon) + " secondary")
	#var weapon_data = WEAPONS[source.weapon]["secondary"]
	#Noise.emit(source.translation, weapon_data["sound"], weapon_data["loudness"])

#func _process(delta):
#	if not Game.playing():
#		return
