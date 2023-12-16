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
		if player._currentGrindRail.get_child(0).progress_ratio >= .90:
			endGrind()
	
func endGrind():
	print(playerGrindBootsTreePos)
	#player._currentGrindRail.reparent(playerGrindBootsTreePos)
	playerGrindBootsTreePos.reparent(player)
	player._currentGrindRail = null
	player.grinding = false
	
	state_machine.transition_to("Air", {do_jump = true})
	
