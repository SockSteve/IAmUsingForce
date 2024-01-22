extends PlayerState

var playerGrindBootsTreePos

func enter(_msg := {}) -> void:
	player.GrindBoots.reparent(player.GrindBoots.currentGrindrail)
	playerGrindBootsTreePos = player.GrindBoots
	pass

func physics_update(delta: float) -> void:
	if player.GrindBoots.currentGrindrail != null:
		player.GrindBoots.currentGrindrail.get_child(0).progress_ratio += delta
		player.global_position = player.GrindBoots.currentGrindrail.get_child(0).global_position
		if player.GrindBoots.currentGrindrail.get_child(0).progress_ratio >= .90:
			endGrind()
	
func endGrind():
	print(playerGrindBootsTreePos)
	playerGrindBootsTreePos.reparent(player)
	player.GrindBoots.end_grind()
	state_machine.transition_to("Air", {do_jump = true})
	
