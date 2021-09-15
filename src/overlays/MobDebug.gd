extends Control

onready var label = $Panel/RichTextLabel

#func _ready():
#	pass

func _process(_delta):
	var lines = [
		"AOIs:     " + PoolStringArray(AreasOfInterest.areas).join(", ")
	]
	
	for idx in len(Mobs.all):
		var mob = Mobs.all[idx]
		if mob == null:
			lines.append("! mobs[" + str(idx) + "] is null.")
		else:
			lines.append(mob.name + " #" + str(idx) + ": " + str(mob.target))
	
	label.clear()
	for idx in range(0, len(lines)):
		label.append_bbcode(lines[idx])
		if idx < (len(lines) - 1):
			label.newline()
