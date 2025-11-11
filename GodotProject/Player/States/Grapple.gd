extends PlayerState

var original_speed = Vector3.ZERO
var swing_origin
var grappleDistance = 600.0
var target_distance_reached: bool = false
var grappling_hook
var release_launch_multiplier: float = 1.5

# Pull-in mechanic settings (Ratchet & Clank style)
var is_pulling_in: bool = false
var pull_in_force: float = 800.0  # Strong pull force (not multiplied by delta)
var pull_in_threshold: float = 2.0  # Stop pulling when within this distance
var joint_attached: bool = false  # Only attach joint after reaching target

func enter(msg := {}) -> void:
	player.putting_ranged_weapon_in_hand_enabled = false
	grappling_hook = player.get_inventory().get_gadget("grappling_hook")

	# Store current velocity for momentum
	original_speed = player.velocity

	player.switch_to_physics_body()
	grappling_hook.activate()
	if not player.is_grappling:
		end_grapple()
		return
	player.character_skin.grapple()

	# Start pull-in for all grapple types
	# Don't attach joint until we reach the target!
	is_pulling_in = true
	target_distance_reached = false
	joint_attached = false


func physics_update(delta: float) -> void:
	# Safety check - make sure we have a valid grapple point
	if not grappling_hook or not grappling_hook.nearest_grapple_point:
		end_grapple()
		return

	# Get movement input from input handler
	var move_input = player.input_handler.get_camera_oriented_input()

	# Handle pull-in phase (swift pull to target distance)
	if is_pulling_in:
		_handle_pull_in(delta)
		return

	# After pull-in, handle different grapple types
	var grapple_type = grappling_hook.nearest_grapple_point.grapple_point_type

	# Check if player should pull itself to target (PULL type)
	if grapple_type == grappling_hook.nearest_grapple_point.grapple_point_type_enum.PULL:
		var direction_to_point: Vector3 = (grappling_hook.nearest_grapple_point.global_position - player.global_position).normalized()
		var pull_force = 15.0
		var velocity_impulse = direction_to_point * pull_force * delta
		player.physics_body.apply_central_impulse(velocity_impulse)

		# Orient character toward grapple point
		player.orient_character_to_direction(-direction_to_point, delta * 0.5)

		# Sync character body with physics body AFTER forces applied
		player.velocity = player.physics_body.linear_velocity
		player.move_and_slide()

	# Check if player should swing around target (SWING type - default)
	elif grapple_type == grappling_hook.nearest_grapple_point.grapple_point_type_enum.SWING:
		# Update persistent move direction on input
		if move_input.length() > 0.2:
			player.move_direction = move_input
			player.last_strong_direction = move_input.normalized()

		# Orient character to movement direction while swinging
		player.orient_character_to_direction(player.last_strong_direction, delta, player.rotation_speed, grappling_hook.direction_normal_to_origin)

		# Sync velocity and move_and_slide FIRST (like old implementation)
		player.velocity = player.physics_body.linear_velocity
		player.move_and_slide()

		# THEN apply force AFTER move_and_slide (this is how the old version worked)
		if move_input != Vector3.ZERO:
			var swing_direction = player.move_direction.normalized()
			var force = swing_direction * 10.0  # Increased from 0.4 to actually move the player
			player.physics_body.apply_central_impulse(force)

	# Hold position near grapple point (HOLD type)
	elif grapple_type == grappling_hook.nearest_grapple_point.grapple_point_type_enum.HOLD:
		# Apply dampening to slow down movement
		player.physics_body.linear_velocity *= 0.95

		# Allow small movements
		if move_input.length() > 0.0:
			var move_force = move_input.normalized() * 0.3
			player.physics_body.apply_central_impulse(move_force)

		# Sync and move AFTER forces applied
		player.velocity = player.physics_body.linear_velocity
		player.move_and_slide()

	# Check for release input (release gadget button to let go)
	if not Input.is_action_pressed("gadget"):
		end_grapple()

func end_grapple():
	# Store current physics velocity
	var launch_velocity = player.physics_body.linear_velocity

	# Sync physics body position
	player.physics_body.global_transform = player.global_transform
	grappling_hook.end_grapple()
	player.switch_to_character_body()

	# Apply launch momentum
	player.velocity = launch_velocity * release_launch_multiplier

	player.putting_ranged_weapon_in_hand_enabled = true
	state_machine.transition_to("Air")
	return

## Strong, immediate pull to target
func _handle_pull_in(delta: float) -> void:
	var grapple_pos = grappling_hook.nearest_grapple_point.global_position
	var player_pos = player.physics_body.global_position
	var target_dist = grappling_hook.nearest_grapple_point.target_distance

	# Calculate current distance to grapple point
	var current_distance = player_pos.distance_to(grapple_pos)

	# Check if we've reached the target distance
	if current_distance <= target_dist + pull_in_threshold:
		is_pulling_in = false
		target_distance_reached = true

		# Attach joint now that we've reached the target
		if not joint_attached:
			grappling_hook.initialize_grappling_mode()
			joint_attached = true

		# Reduce velocity but keep some momentum
		player.physics_body.linear_velocity *= 0.5
		return

	# Calculate direction to grapple point
	var direction_to_point = (grapple_pos - player_pos).normalized()

	# Set velocity directly toward target with massive speed
	var pull_speed = 50.0  # Units per second
	var target_velocity = direction_to_point * pull_speed

	# Blend current velocity with target velocity for smoothness
	player.physics_body.linear_velocity = player.physics_body.linear_velocity.lerp(target_velocity, 0.3)

	# Orient character toward grapple point during pull-in
	player.orient_character_to_direction(-direction_to_point, delta * 5.0)

	# Sync and move
	player.velocity = player.physics_body.linear_velocity
	player.move_and_slide()

	# Allow releasing during pull-in
	if not Input.is_action_pressed("gadget"):
		end_grapple()

var interp_time = 0.0
func move_to_distance(delta) -> bool:
	if player.global_position.distance_to(grappling_hook.nearest_grapple_point.global_position) >= grappling_hook.nearest_grapple_point.target_distance:
		#print(player.global_position.distance_to(grappling_hook.nearest_grapple_point.global_position))
		#print(grappling_hook.nearest_grapple_point.target_distance)
		#interpolate to point
		interp_time += delta
		player.global_position = player.global_position.lerp(grappling_hook.nearest_grapple_point.global_position,interp_time)
		player.move_and_slide()
		target_distance_reached = false
		return false
	interp_time = 0.0
	target_distance_reached = true
	return true
