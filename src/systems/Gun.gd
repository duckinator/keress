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
	var err = Game.connect("load_level", self, "clear_timeouts")
	if err != OK:
		Console.log(str(err))

func _stop_and_remove_all(dict):
	for key in dict:
		var timer = dict[key]
		if timer != null:
			timer.stop()
			remove_child(timer)
		dict.erase(key)

func clear_timeouts(_level):
	_stop_and_remove_all(PRIMARY_TIMEOUTS)
	_stop_and_remove_all(SECONDARY_TIMEOUTS)

func primary(source, raycast):	
	if source.ammo == 0 or (source in PRIMARY_TIMEOUTS and PRIMARY_TIMEOUTS[source] != null):
		return
	
	Console.log(str(source.weapon) + " primary")
	
	primary_timeout_start(source)
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
#	if not Game.playing:
#		return

func primary_timeout_start(source):
	if source in PRIMARY_TIMEOUTS and PRIMARY_TIMEOUTS[source] != null:
		return
	var primary_timeout = Timer.new()
	primary_timeout.wait_time = WEAPONS[source.weapon]["primary"]["timeout"]
	primary_timeout.one_shot = true
	primary_timeout.connect("timeout", self, "primary_timeout_reset", [source])
	add_child(primary_timeout)
	primary_timeout.start()
	PRIMARY_TIMEOUTS[source] = primary_timeout

func primary_timeout_reset(source):
	PRIMARY_TIMEOUTS[source].stop()
	remove_child(PRIMARY_TIMEOUTS[source])
	PRIMARY_TIMEOUTS[source] = null
