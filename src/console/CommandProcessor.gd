extends Node

const HELP = {
	"clear": "clear - clears the console",
	"echo" : "echo <message> - print <message> to the console",
	"teleport x y z": "teleport x y z - teleport the player to coordinates (x, y, z)",
}

const ALIASES = {
	"tp": "teleport",
}

func _ready():
	pass

func clear(_rest):
	Console.clear()

func echo(rest):
	Console.log(rest)

func teleport(rest):
	if not Debug.enabled:
		Console.log("/teleport is only available in debug mode.")
		return
	
	var parts = rest.split(" ", false)
	var nparts = len(parts)
	if nparts != 3:
		Console.error("/teleport expected 3 arguments, got " + str(nparts))
		return
	var pos = Vector3(parts[0], parts[1], parts[2])
	Console.log("Teleporting player to " + str(pos))
	var player = Game.get_player()
	
	if player == null:
		Console.error("??? Game.get_player() returned null ???")
		return
		
	player.translation = pos

func help(rest):
	rest = rest.strip_edges()
	if has_method(rest):
		Console.log(HELP[rest])
	else:
		Console.log("Known commands:")
		for key in HELP.keys():
			Console.log("  " + HELP[key])

func run(line):
	var parts = line.strip_edges().split(" ", false, 1)
	var command = parts[0].to_lower()
	var rest = ""
	if len(parts) > 1:
		rest = parts[1]
	if command[0] == "/":
		command = command.split("/", true, 1)[1]
	
	if has_method(command):
		call(command, rest)
	elif ALIASES.get(command, null) != null:
		call(ALIASES[command], rest)
	else:
		Console.log("No such command: " + str(command))