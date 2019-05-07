extends Spatial

var mobs = []
func _ready():
	Game.restore_player_rotation()

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")