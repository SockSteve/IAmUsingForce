# Run.gd
extends PlayerState

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	if player.is_strafing():
		# In strafe mode: orient to camera direction, move relative to camera
		var camera_forward = (player.camera_controller.camera.global_transform.basis * Vector3.FORWARD).normalized()
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()

		# Smoothly orient to camera direction
		player.orient_character_to_direction(camera_forward, delta * 0.5)
	else:
		# Normal mode: orient to movement direction
		# To not orient quickly to the last input, we save a last strong direction,
		# this also ensures a good normalized value for the rotation basis.
		if player.move_direction.length() > 0.2:
			player.last_strong_direction = player.move_direction.normalized()

		player.orient_character_to_direction(player.last_strong_direction, delta)

	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity := player.velocity.y
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(player.move_direction * player.move_speed, player.acceleration * delta)

	if player.move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
	player.velocity.y += player.gravity * delta
	
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	
	player.character_skin.set_moving(true)
	player.character_skin.set_moving_speed(inverse_lerp(0.0, player.move_speed, xz_velocity.length()))
	
	player.move_and_slide()
	
	# Check for gadget states
	_check_gadget_states()
		
	# Check if stopped moving
	if is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.z, 0.0):
		state_machine.transition_to("Idle")

# Handle input from manager system
func handle_jump() -> void:
	# Check for coyote time or regular ground jump
	if player.is_on_floor() or state_machine.can_coyote_jump():
		if state_machine.can_coyote_jump():
			state_machine.use_coyote_jump()
		state_machine.transition_to("Air", {do_jump = true})

func handle_attack(attack_type: String) -> void:
	if attack_type == "melee":
		state_machine.transition_to("Melee")

func handle_crouch() -> void:
	if player.velocity.length() >= player.slide_start_threshold:
		state_machine.transition_to("Crouch", {do_slide = true})
	else:
		state_machine.transition_to("Crouch")

func _check_gadget_states() -> void:
	if player.get_inventory().has_gadget("grappling_hook"):
		if player.is_grappling:
			state_machine.transition_to("Grapple")
