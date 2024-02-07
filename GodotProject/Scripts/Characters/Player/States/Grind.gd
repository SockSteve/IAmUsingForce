extends PlayerState

var playerGrindBootsTreePos
var grind_boots

func enter(_msg := {}) -> void:
	grind_boots = player.get_gadget("GrindBoots")
	
	grind_boots.reparent(grind_boots.currentGrindrail)
	playerGrindBootsTreePos = grind_boots

func physics_update(delta: float) -> void:
	if grind_boots.currentGrindrail != null:
		grind_boots.currentGrindrail.get_child(0).progress_ratio += delta
		player.global_position = grind_boots.currentGrindrail.get_child(0).global_position
		if grind_boots.currentGrindrail.get_child(0).progress_ratio >= .90:
			endGrind()
	
func endGrind():
	#print(playerGrindBootsTreePos)
	#playerGrindBootsTreePos.reparent(playerGrindBootsTreePos)
	grind_boots.end_grind()
	state_machine.transition_to("Air", {do_jump = true})
	
