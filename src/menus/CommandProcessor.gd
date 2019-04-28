extends Node

func _ready():
	pass

func echo(text):
	Console.log(text)

func run(line):
	var parts = line.strip_edges().split(" ", false, 1)
	var command = parts[0].to_lower()
	var rest = ""
	if len(parts) > 1:
		rest = parts[1]
	if command[0] == "/":
		command = command.split("/", true, 1)[1]
	call(command, rest)