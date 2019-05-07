extends Spatial

var mobs = []
func _ready():
	Game.spawn_player(self)

func player_noise(trans, sound, loudness):
	trans = trans.round()
	Console.log("player_noise(" + str(trans) + ", " + str(sound) + ", " + str(loudness) + ")")

func can_open_door(_door):
	return len(mobs) == 0

func opening_door(door):
	Console.log("Opening door: " + door.name)

func closing_door(door):
	Console.log("Closing door: " + door.name)

func through_door(door):
	Console.log("Went through door: " + str(door))