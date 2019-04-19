extends Spatial

var mobs = []
var grids
func _ready():
	grids = $Grids

	var Floor = new_grid(Vector3(0, 0, 0), Vector3(0, 0, 0))
	var Ceil = new_grid(Vector3(0, 50, 0), Vector3(0, 180, 180))
	var Left = new_grid(Vector3(0, 0, -100), Vector3(90, 180, 180))
	var Right = new_grid(Vector3(0, 0, 100), Vector3(-90, 180, 180))
	var Start = new_grid(Vector3(-10, 0, 0), Vector3(-90, 180, 90))
	var End = new_grid(Vector3(400, 0, 0), Vector3(-90, -180, -90))

	for x in range(-10, 10):
		for z in range(-10, 10):
			# Set the start wall.
			Start.set_cell_item(x, 0, z, 0)
			# Set the end wall.
			End.set_cell_item(x, 0, z, 0)

	# `x` = corridor length.
	for x in range(-2, 200):
		for z in range(-10, 10):
			# Set the floor.
			Floor.set_cell_item(x, 0, z, 1)
			# Set the ceiling.
			Ceil.set_cell_item(x, 0, z, 1)

		for z in range(-10, 10):
			# Set the left wall.
			Left.set_cell_item(x, 1, z, 0)
			# Set the right wall.
			Right.set_cell_item(x, 1, z, 0)

	add_child(Floor)
	add_child(Ceil)
	add_child(Left)
	add_child(Right)
	add_child(Start)
	add_child(End)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func new_grid(translation, rotation):
	var grid = $DummyGridMap.duplicate()
	grid.translation.x = translation.x
	grid.translation.y = translation.y
	grid.translation.z = translation.z
	grid.rotation_degrees.x = rotation.x
	grid.rotation_degrees.y = rotation.y
	grid.rotation_degrees.z = rotation.z
	grid.visible = true
	return grid