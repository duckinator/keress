extends RigidBody

const MAX_SPEED = 50
const MAX_HEALTH = 140
const MASS = 80

var health

var target = null
func _ready():
	self.health = MAX_HEALTH
	self.mass = MASS
	
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	connect("body_entered", self, "_process_body_entered")


func _process(delta):
	pass

func die():
	var scene = get_tree().current_scene
	if scene.has_method("mob_died"):
		scene.mob_died(self)

func cleanup():
	# This can be expanded by adding a death animation and such later.
	queue_free()

func adjust_health(value):
	health = clamp(health + value, 0, MAX_HEALTH)
	Console.debug(str(self) + ".health = " + str(health))
	if health <= 0:
		die()





func vel_to_speed(vel):
	var x = abs(vel.x)
	var y = abs(vel.y)
	var z = abs(vel.z)
	return sqrt((x * x) + (y * y) + (z * z))

func impact_to_force(collider, collider_vel):
	var speed = vel_to_speed(collider_vel)
	return collider.MASS * speed

func force_to_damage(force):
	return ceil(force / 200)

func impact_to_damage(collider, collider_vel):
	var force = impact_to_force(collider, collider_vel)
	return force_to_damage(force)


func _process_body_entered(body):
	if not body.has_method("get_last_velocity"):
		return
	
	if body is RigidBody:
		var vel = body.get_last_velocity()
		var damage = impact_to_damage(body, vel)
		adjust_health(-damage)
	
	if body is KinematicBody:
		if body.translation.y > translation.y:
			var vel = body.get_last_velocity()
			var damage = impact_to_damage(body, vel)
			adjust_health(-damage * 2)
		#if state != ATTACK:
		#	body.adjust_health(-5)
		pass
	else:
		pass
		#set_state(EVADE) # We bumped into the player without seeing them!
	        
	var vel = body.get_last_velocity()
	var height = $MeshInstance.mesh.height
	# If the player is on top of the enemy, it's a curb stomp.
	if floor(body.translation.y) > floor(self.translation.y + height):
		#set_state(EVADE)
		var gravity = Game.get_total_gravity_for(self)
		var damage = impact_to_damage(body, Vector3(vel.x, gravity.y, vel.z))
		adjust_health(-damage)
