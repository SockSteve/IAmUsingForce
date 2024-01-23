extends PlayerState

enum {NULL, PULL, SWING}
var mode = NULL

var original_speed = Vector3.ZERO
@onready var grapplePoints := get_tree().get_nodes_in_group("grapplingPoint")
var grappling := false
var nearestGrapplingPoint
var swing_origin
var grappleDistance = 600.0

func enter(msg := {}) -> void:
	if grapplePoints.is_empty():
		return
	#player.switchToPhysicsBody()
	var grappilingPointDistances := {}
	for grapplingPoint in grapplePoints:
		grapplingPoint.distance = owner.global_transform.origin.distance_to(grapplingPoint.get_grapplingpoint_position())
		grappilingPointDistances[grapplingPoint.distance] = grapplingPoint
	
	var closestGrapplingPoint = grappilingPointDistances[grappilingPointDistances.keys().min()]
	nearestGrapplingPoint = closestGrapplingPoint
	swing_origin = nearestGrapplingPoint.global_position
	
	if closestGrapplingPoint.distance > grappleDistance:
		return
		
	player.switchToPhysicsBody()
		
	if closestGrapplingPoint.is_in_group("grab"):
		mode = PULL
		
	elif closestGrapplingPoint.is_in_group("swing"):
		nearestGrapplingPoint.swingJoint.node_b = player._physics_body.get_path()
		print(nearestGrapplingPoint.swingJoint.node_b)
		mode = SWING
	
#	if msg.has("swing"):
#		player.velocity.y += player.jump_initial_impulse


func physics_update(delta: float) -> void:
	if mode == NULL:
		end_grapple()
	
	if mode == PULL:
		var directionVector: Vector3 = (nearestGrapplingPoint.global_position - player.global_position).normalized()
		var speed = 30
		var velocity = directionVector * speed
		player.velocity = velocity
		player.move_and_slide()
		pass
	
	if mode == SWING:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
			player._move_direction = player._get_camera_oriented_input()
		if player._move_direction.length() > 0.2:
			player._last_strong_direction = player._move_direction.normalized()

		
		player._orient_character_to_direction(player._last_strong_direction, delta)
		
		var input_vector =  player._get_camera_oriented_input()
		
		#check if player is above the grapple point
		# Get positions of the two bodies
		var positionGrapplePoint = nearestGrapplingPoint.global_transform.origin
		var positionPlayer = player.global_transform.origin
		
		if input_vector != Vector3.ZERO:
			input_vector = input_vector.normalized()
			#var swing_direction = player._physics_body.get_global_transform().basis.y.cross(input_vector)
			var swing_direction = player._move_direction
			var force = swing_direction * .4 #speed
			player._physics_body.apply_central_impulse(force)
		
		pass
	print(mode)
		
	if Input.is_action_just_released("gadget"):
		end_grapple()


func end_grapple():
	if mode == SWING:
		nearestGrapplingPoint.swingJoint.node_b = ""
	player.switchToCharacterBody()
	mode = NULL
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
