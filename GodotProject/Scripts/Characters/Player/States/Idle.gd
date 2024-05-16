extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	if not _msg.has("transition"):
		#player.velocity = Vector3.ZERO
		pass
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
		if player.is_grinding:
			state_machine.transition_to("Grind")
		
	if player.get_inventory().has_gadget("GrapplingHook"):
		if player.get_inventory().get_gadget("GrapplingHook").grappling:
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
		state_machine.transition_to("Air", {do_jump = true})
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
	
		
