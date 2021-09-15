extends Spatial

func _ready():
	Enemies.Enemy1.spawn(Vector3(15, 3, -14))
	#Enemies.Enemy1.spawn(Vector3(10, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(0, 3, -10))
	#Enemies.Enemy1.spawn(Vector3(0, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(-10, 3, -12))
	#Enemies.Enemy1.spawn(Vector3(-15, 3, -14))

var won = false
func _process(delta):
	if not won and len(Game.mobs) == 0:
		won = true
		Console.log("woo!")
