extends RayCast

var parent

func _ready():
	parent = get_parent()
	set_cast_to(Vector3(parent.VIEW_DISTANCE, 0, 0))

func _process(delta):
	if not is_colliding():
		parent.found_nothing(self)
		return
	
	var collider = get_collider()
	var position = collider.translation
	if collider is KinematicBody:
		parent.found_player(self, collider, position)
	else:
		parent.found_object(self, collider, position)