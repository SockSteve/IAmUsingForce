extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	player.velocity = Vector3.ZERO


func update(delta: float) -> void:
	
	#check if player is on magnetized ground
	#if player._ground_shapecast.is_colliding():
		##print(player._ground_shapecast.get_collider(0))
		#if player._ground_shapecast.get_collider(0).is_in_group("magnetized"):
			#state_machine.transition_to("Magnet")
	
	if  Input.is_action_pressed("gadget"):
		state_machine.transition_to("Grapple")
		
	# check if player is grinding
	if player.grinding:
		state_machine.transition_to("Grind")
	
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if Input.is_action_just_pressed("ranged_attack"):
		player.up_direction = player.up_direction * -1

	if Input.is_action_just_pressed("jump"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Run")
		
