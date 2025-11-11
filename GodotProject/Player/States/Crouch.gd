extends PlayerState

var slide_time: float = 0
var was_on_floor_last_frame: bool = false

func enter(_msg := {}) -> void:
	player.putting_ranged_weapon_in_hand_enabled = false
	start_crouch()
	if _msg.has("do_slide"):
		start_slide()
	else:
		player.character_skin.crouch()

func physics_update(delta: float) -> void:
	#check if player sliding
	#when sliding you can only jump out of it
	if player.is_sliding:
		# Allow jumping out of slide even when airborne
		if Input.is_action_just_pressed("jump"):
			uncrouch()
			if not player.is_crouching:
				slide_time = 0
				player.putting_ranged_weapon_in_hand_enabled = true
				state_machine.transition_to("Air", {do_crouch_jump = true})
			return

		slide_time += delta * player.slide_strength_curve_time_factor
		slide(delta)

		player.move_and_slide()

		# Track if we were on floor last frame for air transition detection
		was_on_floor_last_frame = player.is_on_floor()

		return
	
	if not player.is_on_floor():
		uncrouch()
		if not player.is_crouching:
			player.putting_ranged_weapon_in_hand_enabled = true
			state_machine.transition_to("Air")
		return
	
	turn_and_move(delta)

	if not Input.is_action_pressed("crouch"):
		#player.character_skin.uncrouch()
		uncrouch()
		if not player.is_crouching:
			player.putting_ranged_weapon_in_hand_enabled = true
			if player.velocity.length() != 0.0:
				state_machine.transition_to("Run")
			else:
				state_machine.transition_to("Idle")
			return
		
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		uncrouch()
		if not player.is_crouching:
			player.putting_ranged_weapon_in_hand_enabled = true
			state_machine.transition_to("Air", {do_crouch_jump = true})

func turn_and_move(delta):
	player.move_direction = player.input_handler.get_camera_oriented_input()

	if player.move_direction.length() > 0.2:
		player.last_strong_direction = player.move_direction.normalized()

	player.orient_character_to_direction(player.last_strong_direction, delta)
	var y_velocity := player.velocity.y

	#change this to remove durifto
	player.velocity = player.velocity.lerp(player.move_direction * player.crouch_move_speed, player.crouch_acceleration * delta)

	if player.move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
	player.velocity.y += player.gravity * delta
	
	var xz_velocity := Vector3(player.velocity.x, 0, player.velocity.z)
	
	player.character_skin.set_crouch_moving(true)
	player.character_skin.set_crouch_moving_speed(inverse_lerp(0.0, player.crouch_move_speed, xz_velocity.length()))

func start_crouch():
	player.collision_shape.shape.height = player.crouching_collision_height
	player.collision_shape.position = player.crouching_collision_position
	player.is_crouching = true

func uncrouch():
	player.collision_shape.shape.height =  player.standing_collision_height
	player.collision_shape.position = player.standing_collision_position
	#we probe for a collision with no motion, to see if the standing hitbox collides
	var result = player.move_and_collide(Vector3.ZERO, true)
	if result!= null:
		start_crouch()
		return
	player.is_crouching = false
	player.is_sliding = false
	player.character_skin.uncrouch()
	
func force_uncrouch():
	player.is_crouching = false
	player.is_sliding = false
	player.collision_shape.position.y = player.collision_shape.position.y * 2
	player.collision_shape.shape.height = player.collision_shape.shape.height * 2
	player.character_skin.uncrouch()

func start_slide():
	player.character_skin.slide()
	player.is_sliding = true

func slide(delta: float):
	var slide_strength: float = player.slide_strength_curve.sample(slide_time) * player.slide_strength_curve_factor
	var slide_direction = player.rotation_root.transform.basis * Vector3.BACK

	# Ground-sticking logic for uneven terrain
	if player.is_on_floor():
		# We're on ground - calculate velocity along the ground surface
		var floor_normal = player.get_floor_normal()

		# Project slide direction onto the floor plane
		var projected_slide = slide_direction - floor_normal * slide_direction.dot(floor_normal)
		projected_slide = projected_slide.normalized()

		# Apply slide velocity along ground
		player.velocity = projected_slide * slide_strength

		# Apply downward force to stick to uneven terrain (floor snap)
		player.velocity.y -= 5.0  # Small downward force to follow terrain contours
	else:
		# We left the ground (jumped or fell off edge) - maintain momentum in air
		# Keep horizontal velocity WITHOUT gravity (slide momentum carries through air)
		var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)

		# If we just left the ground, preserve the slide momentum
		if was_on_floor_last_frame:
			var air_slide_direction = slide_direction
			air_slide_direction.y = 0  # Keep only horizontal component
			air_slide_direction = air_slide_direction.normalized()
			horizontal_velocity = air_slide_direction * slide_strength

		# Maintain horizontal slide velocity, preserve existing Y velocity (no gravity during slide)
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
		# Don't apply gravity - slide momentum carries the player through the air

	player.character_skin.slide()

	if slide_time >= 1:
		player.is_sliding = false
		slide_time = 0.0
