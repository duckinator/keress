extends Spatial

# The number of seconds it takes to open or close a set of doors.
const DOOR_OPEN_SPEED = 0.5
const DOOR_CLOSE_SPEED = 2

# z translations for doors when open and closed.
const DOOR_OPEN_OFFSET = 7
const DOOR_CLOSED_OFFSET = 3

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

func _adjust_light():
	if not is_exit and not locked:
		$Lights/Green.visible = false
		$Lights/Red.visible = false
		return
	
	$Lights/Green.visible = !locked
	$Lights/Red.visible = locked

func _physics_process(delta):
	if state == OPENED or state == CLOSED:
		return
	
	var left_target = null
	var right_target = null
	var door_speed
	if state == OPENING:
		left_target = Vector3(0, 0, -DOOR_OPEN_OFFSET)
		right_target = Vector3(0, 0, DOOR_OPEN_OFFSET)
		door_speed = DOOR_OPEN_SPEED
		state = OPENED
	elif state == CLOSING:
		left_target = Vector3(0, 0, -DOOR_CLOSED_OFFSET)
		right_target = Vector3(0, 0, DOOR_CLOSED_OFFSET)
		door_speed = DOOR_CLOSE_SPEED
		state = CLOSED
	
	if left_target != null:
		$LeftTween.reset_all()
		$LeftTween.interpolate_property(left, "translation", left.translation, left_target, door_speed, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
		$LeftTween.start()

	if right_target != null:
		$RightTween.reset_all()
		$RightTween.interpolate_property(right, "translation", right.translation, right_target, door_speed, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT) 
		$RightTween.start()

func open():
	var scene = get_tree().current_scene
	_adjust_light()
	
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
	_adjust_light()
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