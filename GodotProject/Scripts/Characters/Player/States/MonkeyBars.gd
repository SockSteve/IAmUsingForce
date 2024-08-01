extends PlayerState


func enter(_msg := {}) -> void:
	player.velocity.y = 1

func physics_update(delta: float) -> void:
	turn_and_move(delta)
	player.velocity.y = 1.0
	player.move_and_slide()
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air")

func turn_and_move(delta):
	player._move_direction = player._get_camera_oriented_input()
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if player._move_direction.length() > 0.2:
		player._last_strong_direction = player._move_direction.normalized()
	if player.is_strafing:
		player._last_strong_direction = (player._camera_controller.global_transform.basis * Vector3.BACK).normalized()

	player._orient_character_to_direction(player._last_strong_direction, delta)

	var y_velocity := player.velocity.y
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(player._move_direction * player.move_speed, player.acceleration * delta)
	
	if player._move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
