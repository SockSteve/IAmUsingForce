extends PlayerState
func enter(_msg := {}) -> void:
	start_crouch()
	if _msg.has("do_slide"):
		start_slide()
	else:
		player._character_skin.crouch()

func physics_update(delta: float) -> void:
	if player.sliding:
		slide()
		player.move_and_slide()
		if Input.is_action_just_pressed("jump"):
			player.sliding = false
			player._character_skin.uncrouch()
			state_machine.transition_to("Air", {do_crouch_jump = true})
		return
	#player._character_skin.crouch()
	
	if not player.is_on_floor():
		player._character_skin.uncrouch()
		state_machine.transition_to("Air")
		return
		
	
	player._move_direction = player._get_camera_oriented_input()

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if player._move_direction.length() > 0.2:
		player._last_strong_direction = player._move_direction.normalized()
	#if is_aiming:
		#_last_strong_direction = (_camera_controller.global_transform.basis * Vector3.BACK).normalized()

	player._orient_character_to_direction(player._last_strong_direction, delta)
	

	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity := player.velocity.y
	#change this to remove durifto
	player.velocity = player.velocity.lerp(player._move_direction * player.crouch_move_speed, player.crouch_acceleration * delta)

	if player._move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
	player.velocity.y += player._gravity * delta
	
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	
	player._character_skin.set_crouch_moving(true)
	player._character_skin.set_crouch_moving_speed(inverse_lerp(0.0, player.crouch_move_speed, xz_velocity.length()))
	
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		player._character_skin.uncrouch()
		state_machine.transition_to("Air", {do_crouch_jump = true})
	#elif is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.z, 0.0):
		#player._character_skin.uncrouch()
		#state_machine.transition_to("Idle")
	elif Input.is_action_pressed("gadget"):
		player._character_skin.uncrouch()
		state_machine.transition_to("Grapple")



func start_crouch():
	player.collision_shape.shape.height = player.collision_shape.shape.height / 2
	player.collision_shape.position.y = player.collision_shape.position.y / 2
	
	#var motion_param := PhysicsTestMotionParameters3D.new()
	#motion_param.motion = Vector3.UP
	#PhysicsServer3D.body_test_motion(collision_shape,motion_param) 
	#move_and_collide()
	pass

func uncrouch():
	player.collision_shape.shape.height = player.collision_shape.shape.height * 2
	player.collision_shape.position.y = player.collision_shape.position.y * 2

func start_slide():
	# Start the slide animation
	player._character_skin.slide()
	player.sliding = true
	player.slide_timer.start(player.slide_duration)
	slide()

func slide():
	# Apply an initial forward impulse to the character
	var slide_direction = player._move_direction
	player.velocity = player._rotation_root.transform.basis * Vector3.BACK * player.slide_strength

func _on_slide_timer_timeout():
	player.sliding = false
