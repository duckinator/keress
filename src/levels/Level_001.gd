extends Spatial

signal noise

var mobs = []
func _ready():
	Enemies.spawn(Vector3(15, 30, -14))
	Enemies.spawn(Vector3(10, 30, -12))
	Enemies.spawn(Vector3(0, 30, -10))
	Enemies.spawn(Vector3(0, 30, -12))
	Enemies.spawn(Vector3(-10, 30, -12))
	Enemies.spawn(Vector3(-15, 30, -14))

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func can_open_door(door):
	return (not door.is_exit) or (len(mobs) == 0)

func opening_door(door):
	pass

func closing_door(door):
	pass

func through_door(door):
	pass

func mob_died(mob):
	mobs.remove(mobs.find(mob))
	mob.cleanup()
