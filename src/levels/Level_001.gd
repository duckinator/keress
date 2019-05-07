extends Spatial

var mobs = []
func _ready():
	Game.spawn_player(self)

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