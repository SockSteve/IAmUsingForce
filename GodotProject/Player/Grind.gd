extends PlayerState

var playerGrindBootsTreePos

func enter(_msg := {}) -> void:
	player._grindBoots.reparent(player._currentGrindRail)
	playerGrindBootsTreePos = player._grindBoots
	pass

func physics_update(delta: float) -> void:
	if player._currentGrindRail != null:
		player._currentGrindRail.get_child(0).progress_ratio += delta
		player.global_position = player._currentGrindRail.get_child(0).global_position
		if player._currentGrindRail.get_child(0).progress_ratio >= .99:
			endGrind()
	
func endGrind():
	player._grindBoots.reparent(playerGrindBootsTreePos)
	player._currentGrindRail = null
	player.grinding = false
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
