extends Spatial

enum {OPENED, CLOSED, OPENING, CLOSING}

var state = CLOSED
export var is_exit = false
export var locked = false
export var default_exit_behavior = true
export var seamless_transition = true

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
	var scene = get_tree().current_scene
	
	if state == OPENED or state == OPENING:
		return true
	
	if locked:
		return false
	
	if scene.has_method("can_open_door") and not scene.can_open_door(self):
		return false
	
	state = OPENING
	if scene.has_method("opening_door"):
		return scene.opening_door(self)

func close():
	if state == CLOSED or state == CLOSING:
		return true
	
	state = CLOSING
	var scene = get_tree().current_scene
	if scene.has_method("closing_door"):
		return scene.closing_door(self)

func through():
	var scene = get_tree().current_scene
	if scene.has_method("through_door"):
		scene.through_door(self)
	
	if default_exit_behavior and is_exit:
		Console.log("Went through exit door - going to next level.")
		Game.next_level(seamless_transition)
		default_exit_behavior = false