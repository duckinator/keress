extends Spatial

signal noise

var mobs = []
func _ready():
	spawn_enemy(Vector3(15, 10, -140))
	spawn_enemy(Vector3(10, 10, -120))
	spawn_enemy(Vector3(0, 10, -100))
	spawn_enemy(Vector3(0, 10, -120))
	spawn_enemy(Vector3(-10, 10, -120))
	spawn_enemy(Vector3(-15, 10, -140))

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func can_open_door(door):
	return len(mobs) == 0

func opening_door(door):
	pass

func closing_door(door):
	pass

func through_door(door):
	pass

func mob_died(mob):
	mobs.remove(mobs.find(mob))
	mob.cleanup()

func spawn_enemy(pos):
	var scene = load("res://enemies/enemy1/Enemy1.tscn").instance()
	add_child(scene)
	scene.translate(pos)
	mobs.append(scene)