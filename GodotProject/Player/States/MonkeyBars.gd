extends PlayerState

const MONKEY_BAR_SPEED = 5.0

func physics_update(delta: float) -> void:
	player.slide_on_ceiling = false
	player.floor_constant_speed = true
	
	if not player.is_monkey_bar:
		player.floor_constant_speed = false
		player.slide_on_ceiling = true
		state_machine.transition_to("Air")
		return
	
	var hit_normal: Vector3 = player.get_inventory().get_gadget("grip_gloves").get_collision_normal()
	hit_normal = abs(hit_normal)
	
	var input_dir = player._get_camera_oriented_input()
	
	if input_dir.length() > 0.1:  # Check if there's significant input
		var move_direction = _get_move_direction(input_dir)
		var projected_direction = project_direction_on_plane(move_direction, hit_normal)
		player.velocity = projected_direction * MONKEY_BAR_SPEED
		player._orient_character_to_direction(move_direction, delta)
	else:
		# No input, stop the player
		player.velocity = Vector3.ZERO
	
	#turn_and_move(delta, hit_normal)
	player.move_and_slide()
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air")

func _get_move_direction(input_dir: Vector3) -> Vector3:
	if input_dir.length() > 0.2:
		player._last_strong_direction = input_dir.normalized()
	return player._last_strong_direction

func project_direction_on_plane(direction: Vector3, normal: Vector3) -> Vector3:
	return direction - normal * direction.dot(normal)

func turn_and_move(delta, gravity):
	player._move_direction = player._get_camera_oriented_input()
	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if player._move_direction.length() > 0.2:
		player._last_strong_direction = player._move_direction.normalized()

	player._orient_character_to_direction(player._last_strong_direction, delta)

	var y_velocity := player.velocity.y
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(player._move_direction * player.move_speed, player.acceleration * delta)
	print(gravity)
	player.velocity.x += absf(gravity.x)
	player.velocity.z += gravity.z
	player.velocity.y = gravity.y * 10
	
	if player._move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	#player.velocity.y = gravity.y
