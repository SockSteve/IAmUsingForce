extends PlayerState
func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	#transition to hanging animation
	

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air",{do_jump = true})
