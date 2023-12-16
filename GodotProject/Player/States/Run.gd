# Run.gd
extends PlayerState

func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not player.is_on_floor():
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
#	player.velocity.x = player.speed * Input.get_axis("move_right", "move_left")
#	player.velocity.z = player.speed * Input.get_axis("move_down", "move_up")
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.y, 0.0):
		state_machine.transition_to("Idle")
	elif Input.is_action_pressed("gadget"):
		state_machine.transition_to("Grapple")
