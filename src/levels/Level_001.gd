extends Spatial

func _ready():
	Game.spawn_player(self)

func player_noise(trans, loudness):
	Console.log("Player noise @ " + str(trans) + " with loudness of " + str(loudness))