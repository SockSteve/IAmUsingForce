extends PlayerState
func enter(_msg := {}) -> void:
	player.putting_ranged_weapon_in_hand_enabled = false
	player.velocity = Vector3.ZERO
	#transition to hanging animation
	

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		player.putting_ranged_weapon_in_hand_enabled = true
		state_machine.transition_to("Air",{do_jump = true})
