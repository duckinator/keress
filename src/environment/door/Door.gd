extends Spatial

enum {OPENED, CLOSED, OPENING, CLOSING}

var state = CLOSED
export var is_exit = false
export var locked = false

var left
var right

func _ready():
	set_meta("is_door", true)
	left = $Left_Half
	right = $Right_Half
	close()

func _physics_process(delta):
	if state == OPENED or state == CLOSED:
		return
	
	var left_pos
	var left_target
	var diff
	if state == OPENING:
		left_target = Vector3(0, 0, -2)
		diff = left_target
		left_pos = left.translation.linear_interpolate(left_target, delta)
	else:
		left_target = Vector3(0, 0, 2)
		diff = Vector3(0, 0, 4)
		left_pos = diff.linear_interpolate(left.translation, delta)
	
	if (state == OPENING and left_pos.z <= left_target.z):
		state = OPENED
		left_pos = left_target
	
	if (state == CLOSING and left_pos.z >= left_target.z):
		state = CLOSED
		left_pos = left_target
	
	left.translate(left_pos)

	var right_pos = Vector3(left_pos.x, left_pos.y, -left_pos.z)
	right.translate(right_pos)

func open():
	if state == OPENED or state == OPENING:
		return true
	
	if not get_tree().current_scene.can_open_door(self):
		return false
	
	state = OPENING
	return get_tree().current_scene.opening_door(self)

func close():
	if state == CLOSED or state == CLOSING:
		return true
	
	state = CLOSING
	get_tree().current_scene.closing_door(self)

func through():
	get_tree().current_scene.through_door(self)
