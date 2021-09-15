extends Spatial

var mobs = []
func _ready():
	Enemies.Enemy1.spawn(Vector3(15, 3, -14))
	#Enemies.Enemy1.spawn(Vector3(10, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(0, 3, -10))
	#Enemies.Enemy1.spawn(Vector3(0, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(-10, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(-15, 3, -14))

func can_open_door(door):
	return (not door.is_exit) or (len(mobs) == 0)

func opening_door(door):
	var trans = door.translation
	Noise.emit(trans, "door/open", "10")

func closing_door(door):
	var trans = door.translation
	Noise.emit(trans, "door/close", "10")

func through_door(_door):
	pass

func mob_died(mob):
	mobs.remove(mobs.find(mob))
	mob.cleanup()
