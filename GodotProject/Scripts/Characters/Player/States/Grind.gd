extends PlayerState

#we get the path to follow from the Grindboots when we enter this state
var path_3d : Path3D
var path_follow_3d : PathFollow3D
var is_jumping_between_rails: bool = false
var grind_jump: bool = false
var grind_rail_change: bool = false
var grind_jump_time: float = 0
var path_end: bool = false

#when we enter this state, we set the corresponding animation, get any grindrail related
#information and set the initial progress to set the player on the correct point where he starts grinding
func enter(_msg := {}) -> void:
	player._character_skin.grind()
	path_follow_3d = PathFollow3D.new()
	path_follow_3d.loop = false
	path_3d = player.get_inventory().get_gadget("GrindBoots").current_grindrail
	path_3d.add_child(path_follow_3d)
	set_initial_progress(player.global_transform.origin)

#here we move the player along the path3d throug a path_follow3d
#func update(_delta: float)->void:
	#pass

func physics_update(delta: float) -> void:
	if path_3d == null:
		return
	
	#update player progress
	path_follow_3d.progress_ratio += (delta * player.get_inventory().get_gadget("GrindBoots").grind_speed_time_factor)/path_3d.curve.get_baked_length()
	
	#move player through path_follow_3d
	#we check for grindjump, because when jumping we update our y position, which would otherwise be resetted
	if !grind_jump and not grind_rail_change:
		player.global_position = path_follow_3d.global_position
		print("ye")
	
	player._rotation_root.global_basis = path_follow_3d.global_basis.rotated(Vector3(0,1,0),PI)
	
	if path_follow_3d.progress_ratio >= 1:
		if player.get_inventory().get_gadget("GrindBoots").is_looping:
			path_follow_3d.progress_ratio = 0.0
		else:
			endGrind()
		return
	
	
	
	print(grind_rail_change, ' ', delta)
	#when we have a grindrails next to ours and detect them, we can jump to them 
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_left") and player.get_inventory().get_gadget("GrindBoots").get_side_rail_path3d("left") != null:
			change_grindrail("left")
			grind_rail_change = true
		elif Input.is_action_pressed("move_right") and player.get_inventory().get_gadget("GrindBoots").get_side_rail_path3d("right") != null:
			change_grindrail("right")
			grind_rail_change = true
		#return
	
	if grind_rail_change:
		grind_jump_time += delta
		player.global_position = player.global_position.lerp(path_follow_3d.global_position, grind_jump_time)
		if grind_jump_time >=1:
			grind_jump_time = 0
			grind_rail_change = false
		return
	if Input.is_action_just_pressed("jump") and not grind_rail_change:
		if !grind_jump:
			grind_jump = true
	
	
	if grind_jump:
		player.global_position = path_follow_3d.global_position
		grind_jump_time += delta * player.get_inventory().get_gadget("GrindBoots").grind_curve_time_factor
		var jump_y_pos: float =  player.get_inventory().get_gadget("GrindBoots").grind_jump_curve.sample(grind_jump_time)
		player.global_position.y = path_follow_3d.global_position.y + jump_y_pos
		if grind_jump_time >= 1:
			grind_jump_time = 0.0
			grind_jump = false

#when we first enter the grindrail, we adjust the progress_ratio of the path_follow3d to start grinding
#on the impact point where we jumped on
func set_initial_progress(player_position: Vector3) -> void:
	var local_target_point = path_3d.to_local(player_position)
	var closest_offset = path_3d.curve.get_closest_offset(local_target_point)
	var path_length = path_3d.curve.get_baked_length()
	var progress_ratio = closest_offset / path_length
	path_follow_3d.progress_ratio = progress_ratio


#here we end the grind
#currently the grind state is only exited when the end is reached.
func endGrind():
	grind_jump = false
	grind_jump_time = 0.0
	player._character_skin.end_grind()
	path_follow_3d.queue_free()
	player.get_inventory().get_gadget("GrindBoots").end_grind()
	player.velocity.y = 0
	state_machine.transition_to("Air", {do_jump = true})

func change_grindrail(dir):
	player._character_skin.end_grind()
	path_follow_3d.queue_free()
	#print(path_3d == player.get_inventory().get_gadget("GrindBoots").get_side_rail_path3d(dir))
	path_3d = player.get_inventory().get_gadget("GrindBoots").change_current_grindrail_to(dir)
	#player.get_inventory().get_gadget("GrindBoots").clear_grindrail_exceptions()
	player.can_grind=true
	path_follow_3d = PathFollow3D.new()
	path_follow_3d.loop = false
	path_3d.add_child(path_follow_3d)
	set_initial_progress(player.global_position)
	#player.get_inventory().get_gadget("GrindBoots").end_grind()
	#player.velocity.y = 0.0
	

func _on_jump_completed():
	# Reset jump state, allow for new actions
	is_jumping_between_rails = false
	# Additional logic to lock onto the new rail, if jumping to one
