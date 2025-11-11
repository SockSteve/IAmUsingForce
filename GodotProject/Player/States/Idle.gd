extends PlayerState

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	player.character_skin.set_moving(false)

func update(delta: float) -> void:
	if player.freeze:
		return
	
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
	player.move_and_slide()
	
	player.character_skin.set_moving(false)
	
	# Check for gadget states (grind boots, grappling hook)
	_check_gadget_states()
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	# Movement input check using new system
	if player.move_direction.length() > 0.1:
		state_machine.transition_to("Run")
		return

# Handle input from manager system
func handle_jump() -> void:
	# Check for coyote time or regular ground jump
	if player.is_on_floor() or state_machine.can_coyote_jump():
		if state_machine.can_coyote_jump():
			state_machine.use_coyote_jump()
		state_machine.transition_to("Air", {do_jump = true})

func handle_attack(attack_type: String) -> void:
	if attack_type == "melee":
		state_machine.transition_to("Melee")

func handle_crouch() -> void:
	if not player.is_crouching:
		state_machine.transition_to("Crouch")

func _check_gadget_states() -> void:
	# activating gadget specific states are handled through their specific gadget 
	if player.get_inventory().has_gadget("GrindBoots"):
		#when the player has grindboots and the detect a grindrail, the 
		#player.is_grinding variable is set to true
		if player.is_grinding:
			state_machine.transition_to("Grind")
		
	if player.get_inventory().has_gadget("grappling_hook"):
		if player.is_grappling:
			state_machine.transition_to("Grapple")
			return
	
		
