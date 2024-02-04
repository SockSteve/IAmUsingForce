extends PlayerState
func enter(_msg := {}) -> void:
	if _msg.has("do_slide"):
		# Start the slide animation
		player._character_skin.slide()
		player.sliding = true
		slide()
	else:
		player._character_skin.crouch()

func physics_update(delta: float) -> void:
	if player.sliding:
		player.move_and_slide()
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
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(player._move_direction * player.move_speed, player.acceleration * delta)

	if player._move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
	player.velocity.y += player._gravity * delta
	
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	
	player._character_skin.set_crouch_moving(true)
	player._character_skin.set_crouch_moving_speed(inverse_lerp(0.0, player.move_speed, xz_velocity.length()))
	
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		player._character_skin.uncrouch()
		state_machine.transition_to("Air", {do_jump = true})
	#elif is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.z, 0.0):
		#player._character_skin.uncrouch()
		#state_machine.transition_to("Idle")
	elif Input.is_action_pressed("gadget"):
		player._character_skin.uncrouch()
		state_machine.transition_to("Grapple")

func slide():
	player.slide_timer.start(player.slide_duration)
	# Apply an initial forward impulse to the character
	apply_slide_impulse()

func apply_slide_impulse() -> void:
	var slide_direction = player.global_transform.basis.z.normalized()  # Assumes the character slides forward
	var slide_force = slide_direction * player.slide_impulse
	# Apply the force to the character's physics body
	# This will vary depending on whether you're using KinematicBody or RigidBody
