# Run.gd
extends PlayerState

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	player._move_direction = player._get_camera_oriented_input()

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if player._move_direction.length() > 0.2:
		player._last_strong_direction = player._move_direction.normalized()
		
	if player.is_strafing:
		player._last_strong_direction = (player._camera_controller.camera.global_transform.basis * Vector3.FORWARD).normalized()

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
	
	player._character_skin.set_moving(true)
	player._character_skin.set_moving_speed(inverse_lerp(0.0, player.move_speed, xz_velocity.length()))
	
	player.move_and_slide()
	
	if  Input.is_action_pressed("melee_attack"):
		state_machine.transition_to("Melee")
		return
	
	if Input.is_action_just_pressed("crouch"):
		if player.velocity.length() >= player.slide_start_threshhold:
			state_machine.transition_to("Crouch",{do_slide = true})
		state_machine.transition_to("Crouch")
		return
		
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
		return
		
	elif is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.z, 0.0):
		state_machine.transition_to("Idle")
		#return
		
	if player.get_inventory().has_gadget("grappling_hook") and Input.is_action_pressed("interact"):
		player.get_inventory().get_gadget("grappling_hook").activate()
		if player.is_grappling:
			state_machine.transition_to("Grapple")
		return
