extends PlayerState

var slide_time: float = 0

func enter(_msg := {}) -> void:
	player.putting_ranged_weapon_in_hand_enabled = false
	start_crouch()
	if _msg.has("do_slide"):
		start_slide()
	else:
		player._character_skin.crouch()

func physics_update(delta: float) -> void:
	#check if player sliding
	#when sliding you can only jump out of it
	if player.is_sliding:
		slide_time += delta * player.slide_strength_curve_time_factor
		slide()
		
		player.move_and_slide()
		if Input.is_action_just_pressed("jump"):
			uncrouch()
			if not player.is_crouching:
				slide_time = 0
				player.putting_ranged_weapon_in_hand_enabled = true
				state_machine.transition_to("Air", {do_crouch_jump = true})
		return
	
	if not player.is_on_floor():
		uncrouch()
		if not player.is_crouching:
			player.putting_ranged_weapon_in_hand_enabled = true
			state_machine.transition_to("Air")
		return
	
	turn_and_move(delta)

	if not Input.is_action_pressed("crouch"):
		#player._character_skin.uncrouch()
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
	player._move_direction = player._get_camera_oriented_input()

	if player._move_direction.length() > 0.2:
		player._last_strong_direction = player._move_direction.normalized()

	player._orient_character_to_direction(player._last_strong_direction, delta)
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
	player._character_skin.uncrouch()
	
func force_uncrouch():
	player.is_crouching = false
	player.is_sliding = false
	player.collision_shape.position.y = player.collision_shape.position.y * 2
	player.collision_shape.shape.height = player.collision_shape.shape.height * 2
	player._character_skin.uncrouch()

func start_slide():
	player._character_skin.slide()
	player.is_sliding = true

func slide():
	var slide_strength: float = player.slide_strength_curve.sample(slide_time) * player.slide_strength_curve_factor
	player.velocity = player._rotation_root.transform.basis * Vector3.BACK * slide_strength
	player._character_skin.slide()
	if slide_time >= 1:
		player.is_sliding = false
		slide_time = 0.0
