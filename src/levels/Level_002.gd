extends Spatial

var mobs = []
func _ready():
	#Enemies.spawn(Vector3(-30, 30, -40))
	#Enemies.spawn(Vector3(0, 30, -10))
	#Enemies.spawn(Vector3(0, 30, -65))
	#Enemies.spawn(Vector3(30, 30, -40))
	pass

func mob_died(mob):
	Console.log("MOB DIED: " + str(mob))
	mobs.remove(mobs.find(mob))
	mob.cleanup()
