extends Spatial

var mobs = []
func _ready():
	spawn_enemy(Vector3(-30, 30, -40))
	spawn_enemy(Vector3(0, 30, -10))
	spawn_enemy(Vector3(0, 30, -65))
	spawn_enemy(Vector3(30, 30, -40))

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func mob_died(mob):
	Console.log("MOB DIED: " + str(mob))
	mobs.remove(mobs.find(mob))
	mob.cleanup()

func spawn_enemy(pos):
	var scene = load("res://enemies/enemy1/Enemy1.tscn").instance()
	add_child(scene)
	scene.translate(pos)
	mobs.append(scene)