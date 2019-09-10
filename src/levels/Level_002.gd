extends Spatial

signal noise

var mobs = []
func _ready():
	Enemies.spawn(Vector3(-30, 30, -40))
	Enemies.spawn(Vector3(0, 30, -10))
	Enemies.spawn(Vector3(0, 30, -65))
	Enemies.spawn(Vector3(30, 30, -40))

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func update_door_locks():
	if len(mobs) == 0:
		$ExitDoor.locked = false

func mob_died(mob):
	Console.log("MOB DIED: " + str(mob))
	mobs.remove(mobs.find(mob))
	mob.cleanup()
