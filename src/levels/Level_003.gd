extends Spatial

signal noise

var mobs = []
func _ready():
	# $Platform
	Enemies.spawn_horde(Vector3(-56, 3, 40), Vector2(30, 100), 3)
	Enemies.spawn_horde(Vector3(-56, 3, -180), Vector2(30, 100), 3)
	
	# $Platform_Left
	Enemies.spawn_horde(Vector3(-370, -27, 150), Vector2(280, 30), 20)
	# $Platform_Right
	Enemies.spawn_horde(Vector3(-370, -27, -180), Vector2(280, 30), 20)
	
	# $Platform_Mid
	Enemies.spawn_horde(Vector3(-220, -55, -182), Vector2(30, 400), 16)

func player_noise(trans, sound, loudness):
	trans = trans.round()
	emit_signal("noise", trans, sound, loudness)

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
