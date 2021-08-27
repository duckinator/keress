extends Control

onready var label = $Panel/RichTextLabel

#func _ready():
#	pass

func _process(_delta):
	var lines = [
		"AOIs:     " + PoolStringArray(AreasOfInterest.areas).join(", ")
	]
	
	for idx in len(AreasOfInterest.mobs):
		var mob = AreasOfInterest.mobs[idx]
		lines.append(mob.name + " #" + str(idx) + ": " + str(mob.target))
	
	label.clear()
	for idx in range(0, len(lines)):
		label.append_bbcode(lines[idx])
		if idx < (len(lines) - 1):
			label.newline()
