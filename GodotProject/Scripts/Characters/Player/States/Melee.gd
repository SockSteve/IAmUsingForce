extends PlayerState



func enter(_msg := {}) -> void:
	$"../../AttackTimer".timeout.connect(attack_ended)
	$"../../ComboTimer".timeout.connect(combo_ended)
	player.switch_current_weapon_to_melee(true)
	player.is_melee = true
	
	if _msg.has("do_air_up_attack"):
		attack("up")
		print("up")
		$"../../AttackTimer".start()
		return
	if _msg.has("do_air_down_attack"):
		attack("down")
		print("down")
		return
	
	player._character_skin.attack(player.combo_step)
	player.combo_step += 1

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += player._gravity * delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("melee_attack") and not player.is_on_floor(): #and not player.is_attacking:
		attack("")
	
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("crouch"):
		player.combo_step = 0
		state_machine.transition_to("Crouch", {do_slide = true})

	
	if Input.is_action_just_pressed("jump"):
		player.combo_step = 0
		state_machine.transition_to("Air", {do_jump = true})

func attack(air_up_down: StringName):
	if air_up_down == "up":
		player._character_skin.air_attack("up")
		return
	if air_up_down == "down":
		player._character_skin.air_attack("down")
		return
	
	player.is_melee = true
	var advance_distance = 10.0  # Adjust as needed
	#var advance_direction = -player.global_transform.basis.z.normalized()  # Forward direction, -z is forward
	var advance_direction = player._rotation_root.transform.basis.z.normalized() 
	
	match player.combo_step:
		0:
			player._character_skin.attack(player.combo_step)
			move_character(advance_direction, advance_distance)
			player.combo_step += 1
		1:
			player._character_skin.attack(player.combo_step)
			move_character(advance_direction, advance_distance)
			player.combo_step += 1
		2:
			player._character_skin.attack(player.combo_step)
			move_character(advance_direction, advance_distance)
			player.combo_step = 0  # Reset combo after third attack
	

func move_character(direction: Vector3, distance: float):
	var motion = direction * distance
	player.velocity = motion
	player.move_and_slide()
	

func attack_ended():
	pass
	
func combo_ended():
	pass
