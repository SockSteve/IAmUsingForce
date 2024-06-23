extends PlayerState

var original_speed = Vector3.ZERO
var swing_origin
var grappleDistance = 600.0
var target_distance_reached: bool = false
var grappling_hook

func enter(msg := {}) -> void:
	player.putting_ranged_weapon_in_hand_enabled = false
	grappling_hook = player.get_inventory().get_gadget("GrapplingHook")
	
	player.switchToPhysicsBody()
	grappling_hook.activate()
	if not player.is_grappling:
		end_grapple()
		return
	player._character_skin.grapple()


func physics_update(delta: float) -> void:
	
	#if not target_distance_reached:
		#move_to_distance(delta)
		#print("not yet")
		#return
	#
	## check if player should pull itself to target
	if grappling_hook.nearest_grapple_point.grapple_point_type == grappling_hook.nearest_grapple_point.grapple_point_type_enum.PULL:
		var directionVector: Vector3 = (grappling_hook.nearest_grapple_point.global_position - player.global_position).normalized()
		var speed = 9
		var velocity_force = directionVector * speed
		player._physics_body.apply_central_impulse(velocity_force)
		player.velocity = player._physics_body.linear_velocity
		player.move_and_slide()
		pass
	
	
	#check if player should swing around target
	if grappling_hook.nearest_grapple_point.grapple_point_type == grappling_hook.nearest_grapple_point.grapple_point_type_enum.SWING:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
			player._move_direction = player._get_camera_oriented_input()
		if player._move_direction.length() > 0.2:
			player._last_strong_direction = player._move_direction.normalized()
		
		player._orient_character_to_direction(player._last_strong_direction, delta,player._rotation_speed, grappling_hook.direction_normal_to_origin)
		#player._orient_character_to_direction(player._last_strong_direction, delta)
		
		var input_vector =  player._get_camera_oriented_input()
		
		player.velocity = player._physics_body.linear_velocity
		player.move_and_slide()
		if input_vector != Vector3.ZERO:
			input_vector = input_vector.normalized()
			#var swing_direction = player._physics_body.get_global_transform().basis.y.cross(input_vector)
			var swing_direction = player._move_direction
			var force = swing_direction * .4 #speed
			player._physics_body.apply_central_impulse(force)
		pass
	
	if not Input.is_action_pressed("interact"):
		player.velocity = player._physics_body.linear_velocity
		player.move_and_slide()
		end_grapple()

func end_grapple():
	player._physics_body.global_transform = player.global_transform
	grappling_hook.end_grapple()
	player.switchToCharacterBody()
	print("here")
	player.putting_ranged_weapon_in_hand_enabled = true
	state_machine.transition_to("Air")
	return

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
