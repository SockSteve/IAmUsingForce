extends PlayerState

var path_3d : Path3D
var path_follow_3d : PathFollow3D

func enter(_msg := {}) -> void:
	player._character_skin.grind()
	path_follow_3d = PathFollow3D.new()
	path_3d = player.get_gadget("GrindBootsV2").current_grindrail
	path_3d.add_child(path_follow_3d)
	set_initial_progress(player.global_transform.origin)
	

func physics_update(delta: float) -> void:
	if path_3d != null:
		#print(path_follow_3d.progress_ratio)
		path_follow_3d.progress_ratio += delta * 0.5
		player.global_transform = path_follow_3d.global_transform
		if path_follow_3d.progress_ratio >= .98:
			endGrind()
			return

func set_initial_progress(player_position: Vector3) -> void:
	#print(path_3d.curve.get_closest_offset(player_position))
	#print(path_3d.curve.get_baked_length())
	
	#var closest_offset = path_3d.curve.get_closest_offset(player_position)
	#path_follow_3d.progress_ratio = closest_offset
	
	var local_target_point = path_3d.to_local(player_position)
	var closest_offset = path_3d.curve.get_closest_offset(local_target_point)
	var path_length = path_3d.curve.get_baked_length()
	var progress_ratio = closest_offset / path_length
	path_follow_3d.progress_ratio = progress_ratio
	
	var mesh : MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	path_3d.add_child(mesh)
	mesh.global_position = path_follow_3d.global_position

func endGrind():
	player._character_skin.end_grind()
	path_follow_3d.queue_free()
	player.get_gadget("GrindBootsV2").end_grind()
	player.velocity.y = 0.0
	state_machine.transition_to("Air", {do_jump = true})
	
	
func start_jump_to_rail(target_rail: Path3D):
	var start_point = player.global_transform.origin
	var end_point = target_rail.global_transform.origin  # Simplified; adjust based on actual target position on the rail
	var apex_point = start_point.linear_interpolate(end_point, 0.5) + Vector3.UP * 10  # Adjust the height

	# Ensure any existing tween is stopped
	$Tween.stop_all()

	# Animate to the apex
	$Tween.interpolate_property(player, "global_transform.origin",
								start_point, apex_point,
								0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)

	# Chain the animation from the apex to the end point
	$Tween.interpolate_property(player, "global_transform.origin",
								apex_point, end_point,
								0.5, Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)  # Delay start by the duration of the first tween

	$Tween.start()
	$Tween.connect("tween_all_completed", self, "_on_jump_completed")

func _on_jump_completed():
	# Reset jump state, allow for new actions
	is_jumping_between_rails = false
	# Additional logic to lock onto the new rail, if jumping to one
