#Grapple.gd
extends PlayerState

enum {PULL, SWING}
var mode = PULL 

var original_speed = Vector3.ZERO
@onready var grapplePoints := get_tree().get_nodes_in_group("grapplingPoint")
var grappling := false

func enter(msg := {}) -> void:
	if grapplePoints.is_empty():
		return
	var grappilingPointDistances := {}
	for grapplingPoint in grapplePoints:
		grapplingPoint.distance = owner.global_transform.origin.distance_to(grapplingPoint.get_grapplingpoint_position())
		grappilingPointDistances[grapplingPoint.distance] = grapplingPoint
	
	var closestGrapplingPoint = grappilingPointDistances[grappilingPointDistances.keys().min()]
	
	if closestGrapplingPoint.distance > owner.grappleDistance:
		return
		
	if closestGrapplingPoint.is_in_group("grab"):
		mode = PULL
	elif closestGrapplingPoint.is_in_group("swing"):
		mode = SWING
	
#	if msg.has("swing"):
#		player.velocity.y += player.jump_initial_impulse


func physics_update(delta: float) -> void:
	
	if mode == PULL:
		return
	
	if mode == SWING:
		return
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
#	grappling = true
#	if grappling:
#		grapple(delta)
#	else:
#		# your usual character movement logic goes here
#		pass
#	print(player)
#	if Input.is_action_pressed("gadget") and not owner.is_grapple_attached:
#		owner.switchToPhysicsBody()
#		owner.grapple_point = get_nearest_visible_grapple_point()
#		if owner.grapple_point:
#			owner.grapple_distance = owner.grapple_point.position - owner.position
#			owner.velocity = owner.grapple_distance.normalized() * owner.grapple_speed
#			owner.is_grapple_attached = true
#	elif Input.is_action_pressed("gadget") and owner.is_grapple_attached:
#		owner.switchToCharacterBody()
#		owner.grapple_point = null
#		owner.grapple_distance = Vector3.ZERO
#		owner.is_grapple_attached = false
#
#	if owner.is_grapple_attached:
#		var swing_direction = owner.grapple_distance.normalized()
#		var swing_velocity = swing_direction * owner.grapple_swing_speed
#		owner._physics_body.angular_velocity = swing_velocity
#
#func get_nearest_visible_grapple_point():
#	var nearest_grapple_point = null
#	var nearest_distance = 10000
#	for grapple_point in owner.grapple_points:
#		if grapple_point.is_visible():
#			var distance = hook.global_transform.origin - owner.position #owner.grapple_point.position - owner.position
#			if distance.length() < nearest_distance:
#				nearest_distance = distance
#				nearest_grapple_point = grapple_point
#	return nearest_grapple_point
#
#func grapple(delta):
#	# calculate the direction from the grapple point to the character
#	owner.grapple_point = get_nearest_visible_grapple_point()
#	var grapple_to_char_direction = (owner.global_transform.origin - owner.grapple_point.position).normalized()
#
#	# calculate the new position of the character along the circular path
#	var new_pos = owner.grapple_point.position + grapple_to_char_direction #grapple_distance 
# # calculate the difference between the current position and the new position
#	var pos_diff = new_pos - owner.global_transform.origin
#
#	# set the new velocity based on the position difference and the original speed
#	owner.velocity = pos_diff / delta + original_speed * 10.0
#	player.move_and_slide()
#
## this function is called when the character uses the grappling hook
#func start_grappling():
#	grapple_point = hook.global_transform.origin
#	original_speed = owner.velocity
#	grappling = true
#
## this function is called when the character stops grappling
#func stop_grappling():
#	grappling = false

#@export var grapple_distance : float = 15.0
#@export var grapple_speed : float = 10.0
#
#var grapple_angle : float = 180.0
#
#
#func grapple(delta):
#	grapple_angle += grapple_speed * delta
#	var target_position = grapple_point.global_transform.origin + Vector3(cos(grapple_angle), 0, sin(grapple_angle)) * grapple_distance
#	var direction_to_target = target_position - owner.global_transform.origin
#
#	# move_and_slide is used here to handle collision with the environment
#	owner.velocity = direction_to_target.normalized() * grapple_speed
#	owner.move_and_slide()#direction_to_target.normalized() * grapple_speed)
#
## This function is called when the character uses the grappling hook
#func start_grappling():
#	# The angle is calculated from the current position of the player in relation to the grapple point
#	var relative_position = owner.global_transform.origin - grapple_point.global_transform.origin
#	grapple_angle = atan2(relative_position.z, relative_position.x)
#	grappling = true
#
## This function is called when the character stops grappling
#func stop_grappling():
#	grappling = false
