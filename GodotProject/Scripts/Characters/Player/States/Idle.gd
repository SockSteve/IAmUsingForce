extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	#player.velocity = Vector3.ZERO
	player._character_skin.set_moving(false)
	

func update(delta: float) -> void:
	if player.freeze:
		return
	
	player._character_skin.set_moving(false)
	if  Input.is_action_pressed("gadget"):
		state_machine.transition_to("Grapple")
		
	if  Input.is_action_pressed("melee_attack"):
		state_machine.transition_to("Melee")
		
	# check if player is grinding
	if player.get_gadget("GrindBootsV2").grinding:
		state_machine.transition_to("Grind")
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Crouch")
		

	if Input.is_action_just_pressed("jump"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Run")
		
