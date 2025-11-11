# Air.gd
extends PlayerState

var jumped: bool = false

func enter(msg := {}) -> void:
	player.character_skin.fall()
	if msg.has("do_jump"):
		player.velocity.y += player.jump_initial_impulse
		player.character_skin.jump()
		jumped = true
		
	if msg.has("do_crouch_jump"):
		player.velocity.y = player.crouch_jump_initial_impulse
		player.character_skin.jump()
		jumped = true
		
	if msg.has("do_launch"):
		player.velocity.y += player.launch_initial_impulse
		player.character_skin.jump()
	
	if msg.has("do_grind_end_launch"):
		player.velocity.y += player.grind_end_launch_initial_impulse
		player.character_skin.jump()

#TODO acending and decending checks for melee attack
#TODO overhaul jump logic and add support for double jump 
func physics_update(delta: float) -> void:
	turn_and_move(delta)
	
	if player.velocity.y > -1 and player.velocity.y < 1:
		player.velocity.y += player.jump_apex_gravity * delta
	else:
		player.velocity.y += player.gravity * delta
		
	# Variable jump height - release jump early to reduce jump height
	if jumped and not Input.is_action_pressed("jump") and player.velocity.y > 7.5:
		player.velocity.y = 7.5
	
	player.move_and_slide()
	
	# Ledge detection when falling
	_check_ledge_grab()
	
	# Check for gadget states
	_check_gadget_states()
	
	if player.is_monkey_bar:
		jumped = false
		state_machine.transition_to("MonkeyBars")
	
	if player.is_on_floor():
		jumped = false
		if is_equal_approx(player.velocity.x, 0.0):
			player.character_skin.set_moving(false)
			state_machine.transition_to("Idle")
		else:
			player.character_skin.set_moving(true)
			state_machine.transition_to("Run")

# Handle input from manager system
func handle_jump() -> void:
	# Coyote time jump - can jump for a brief moment after leaving the ground
	if state_machine.can_coyote_jump() and not jumped:
		state_machine.use_coyote_jump()
		player.velocity.y = player.jump_initial_impulse
		player.character_skin.jump()
		jumped = true

func handle_attack(attack_type: String) -> void:
	if attack_type == "melee":
		if player.velocity.y <= 0:
			state_machine.transition_to("Melee", {do_air_down_attack = true})
		elif player.velocity.y > 0 and Input.is_action_pressed("jump"):
			state_machine.transition_to("Melee", {do_air_up_attack = true})

func _check_ledge_grab() -> void:
	# Only check for ledges when falling (not jumping up)
	if player.velocity.y >= -2.0:  # Allow small downward velocity threshold
		return

	# Verify raycasts exist and are enabled
	if not player.ledge_ray_vertical or not player.ledge_ray_horizontal:
		return

	if not player.ledge_ray_vertical.enabled or not player.ledge_ray_horizontal.enabled:
		return

	# Step 1: Vertical raycast detects a potential ledge surface
	player.ledge_ray_vertical.force_raycast_update()
	if not player.ledge_ray_vertical.is_colliding():
		return

	var ledge_height = player.ledge_ray_vertical.get_collision_point().y
	var ledge_normal = player.ledge_ray_vertical.get_collision_normal()

	# Make sure the surface is relatively horizontal (ledge top, not a wall)
	if ledge_normal.y < 0.7:  # Must be more horizontal than 45 degrees
		return

	# Step 2: Position horizontal ray at the detected ledge height
	# Offset slightly below the surface to detect the wall face
	player.ledge_ray_horizontal.global_position.y = ledge_height - 0.15
	player.ledge_ray_horizontal.force_raycast_update()

	# Step 3: Horizontal ray confirms there's a wall in front
	if not player.ledge_ray_horizontal.is_colliding():
		return

	var wall_normal = player.ledge_ray_horizontal.get_collision_normal()

	# Make sure it's actually a wall (not floor/ceiling)
	if abs(wall_normal.y) > 0.3:  # Wall should be mostly vertical
		return

	# All checks passed - grab the ledge!
	var ledge_data = {
		"ledge_position": player.ledge_ray_vertical.get_collision_point(),
		"wall_position": player.ledge_ray_horizontal.get_collision_point(),
		"wall_normal": wall_normal
	}

	state_machine.transition_to("LedgeHang", ledge_data)

func _check_gadget_states() -> void:
	if player.get_inventory().has_gadget("grappling_hook"):
		if player.is_grappling:
			jumped = false
			state_machine.transition_to("Grapple")
			return
	
	if player.get_inventory().has_gadget("grind_boots"):
		if player.is_grinding:
			jumped = false
			state_machine.transition_to("Grind")
			return



# Logic for turning and moving
func turn_and_move(delta):
	# Use movement input from new system
	var move_direction = player.move_direction

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
		if move_direction.length() > 0.2:
			player.last_strong_direction = move_direction.normalized()

		player.orient_character_to_direction(player.last_strong_direction, delta)

	var y_velocity := player.velocity.y
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(move_direction * player.move_speed, player.acceleration * delta)

	if move_direction.length() == 0 and player.velocity.length() < player.stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity
