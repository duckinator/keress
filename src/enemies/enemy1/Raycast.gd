extends RayCast

var parent

func _ready():
	parent = get_parent()

func _process(delta):
	if not is_colliding():
		parent.found_nothing(self)
		return
	
	var collider = get_collider()
	
	if collider == null:
		Console.error("Placeholder_Enemy/Raycast.gd: _process(): Somehow, collider == null")
		return
	
	var position = collider.translation
	if collider is KinematicBody:
		parent.found_player(self, collider, position)
	else:
		parent.found_object(self, collider, position)
