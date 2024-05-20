extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	player._character_skin.set_moving(false)

func update(delta: float) -> void:
	if player.freeze:
		return
	
	if not player.is_on_floor():
		player.velocity.y -= player._gravity * delta
	player.move_and_slide()
	
	player._character_skin.set_moving(false)
	
	if  Input.is_action_pressed("melee_attack"):
		state_machine.transition_to("Melee")
		return
	
	
	# activating gadget specific states are handled through their specific gadget 
	if player.get_inventory().has_gadget("GrindBoots"):
		#when the player has grindboots and the detect a grindrail, the 
		#player.is_grinding variable is set to true
		if player.is_grinding:
			state_machine.transition_to("Grind")
		
	if player.get_inventory().has_gadget("GrapplingHook") and Input.is_action_pressed("interact"):
		player.get_inventory().get_gadget("GrapplingHook").activate()
		if player.is_grappling:
			state_machine.transition_to("Grapple")
			return
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Run")
		return
		
	
	if Input.is_action_pressed("crouch") and not player.is_crouching:
		state_machine.transition_to("Crouch")
		return

	if Input.is_action_just_pressed("jump"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Air", {do_jump = true})
	
		
