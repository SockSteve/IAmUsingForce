# Air.gd
extends PlayerState

var jumped: bool = false

func enter(msg := {}) -> void:
	player._character_skin.fall()
	if msg.has("do_jump"):
		player.velocity.y += player.jump_initial_impulse
		player._character_skin.jump()
		jumped = true
		
	if msg.has("do_crouch_jump"):
		player.velocity.y += player.crouch_jump_initial_impulse
		player._character_skin.jump()
		jumped = true
		
	if msg.has("do_launch"):
		player.velocity.y += player.launch_initial_impulse
		player._character_skin.jump()
	
	if msg.has("do_grind_end_launch"):
		player.velocity.y += player.grind_end_launch_initial_impulse
		player._character_skin.jump()

#TODO acending and decending checks for melee attack
#TODO overhaul jump logic and add support for double jump 
func physics_update(delta: float) -> void:
	turn_and_move(delta)
	
	if player.velocity.y > -1 and player.velocity.y < 1 :
		player.velocity.y += player.jump_apex_gravity * delta
	else:
		player.velocity.y += player._gravity * delta
		
	if jumped and not Input.is_action_pressed("jump") and player.velocity.y > 7.5:
		player.velocity.y = 7.5
	
	player.move_and_slide()
	
	#when player is falling down, check if any ledges are nearby
	if player.velocity.y <= 0:
		#print("je")
		player.ledge_ray_vertical.force_raycast_update()
		#print(player.ledge_ray_vertical.is_colliding())
		if player.ledge_ray_vertical.is_colliding():
			print("jere1")
			player.ledge_ray_horizontal.global_position.y = player.ledge_ray_vertical.get_collision_point().y - 0.01
			player.ledge_ray_horizontal.force_raycast_update()
			if player.ledge_ray_horizontal.is_colliding():
				print("jere2")
				state_machine.transition_to("LedgeHang")
				return
	
	
	if Input.is_action_just_pressed("melee_attack"):
		if player.velocity.y <= 0:
			state_machine.transition_to("Melee", {do_air_down_attack = true})
			return
		if player.velocity.y > 0 and Input.is_action_pressed("jump"):
			state_machine.transition_to("Melee", {do_air_up_attack = true})
			return
	
	if player.get_inventory().has_gadget("grappling_hook") and Input.is_action_pressed("interact"):
		player.get_inventory().get_gadget("grappling_hook").activate()
		if player.is_grappling:
			jumped = false
			state_machine.transition_to("Grapple")
			return
	
	if player.get_inventory().has_gadget("grind_boots"):
		if player.is_grinding:
			jumped = false
			state_machine.transition_to("Grind")
			return
	
	if player.is_monkey_bar:
		jumped = false
		state_machine.transition_to("MonkeyBars")
	
	if player.is_on_floor():
		jumped = false
		if is_equal_approx(player.velocity.x, 0.0):
			player._character_skin.set_moving(false)
			state_machine.transition_to("Idle")
		else:
			player._character_skin.set_moving(true)
			state_machine.transition_to("Run")



#logic for turning and moving
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
