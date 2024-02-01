extends PlayerState

enum {NULL, PULL, SWING}
var mode = NULL

var original_speed = Vector3.ZERO
var grappling := false
var nearest_grapple_point
var swing_origin
var grappleDistance = 600.0
var grappling_hook

func enter(msg := {}) -> void:
	grappling_hook = player.get_gadget("GrapplingHook")
	grappling_hook.activate()
	nearest_grapple_point = grappling_hook.nearest_grapple_point
	swing_origin = grappling_hook.grapple_point_global_position
	
	if nearest_grapple_point.distance > grappleDistance:
		return
		
	player.switchToPhysicsBody()
		
	if nearest_grapple_point.is_in_group("grab"):
		mode = PULL
		
	elif nearest_grapple_point.is_in_group("swing"):
		nearest_grapple_point.swingJoint.node_b = player._physics_body.get_path()
		print(nearest_grapple_point.swingJoint.node_b)
		mode = SWING


func physics_update(delta: float) -> void:
	if mode == NULL:
		end_grapple()
	
	if mode == PULL:
		var directionVector: Vector3 = (nearest_grapple_point.global_position - player.global_position).normalized()
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
		var positionGrapplePoint = nearest_grapple_point.global_transform.origin
		var positionPlayer = player.global_transform.origin
		player.velocity = player._physics_body.linear_velocity
		player.move_and_slide()
		if input_vector != Vector3.ZERO:
			input_vector = input_vector.normalized()
			#var swing_direction = player._physics_body.get_global_transform().basis.y.cross(input_vector)
			var swing_direction = player._move_direction
			var force = swing_direction * .4 #speed
			player._physics_body.apply_central_impulse(force)
		
		pass
	#print(mode)
		
	if Input.is_action_just_released("gadget"):
		end_grapple()


func end_grapple():
	if mode == SWING:
		nearest_grapple_point.swingJoint.node_b = ""
	grappling_hook.end_grapple()
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
