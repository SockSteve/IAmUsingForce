extends PlayerState

var path_3d
var path_follow_3d

func enter(_msg := {}) -> void:
	path_follow_3d = PathFollow3D.new()
	path_3d = player.get_gadget("GrindBootsV2").current_grindrail
	path_3d.add_child(path_follow_3d)
	

func physics_update(delta: float) -> void:
	if path_3d != null:
		path_follow_3d.progress_ratio += delta
		player.global_position = path_follow_3d.global_position
		if path_follow_3d.progress_ratio >= .98:
			endGrind()
			return
	
func endGrind():
	path_follow_3d.queue_free()
	player.get_gadget("GrindBootsV2").end_grind()
	player.velocity.y = 0.0
	state_machine.transition_to("Air", {do_jump = true})
	
