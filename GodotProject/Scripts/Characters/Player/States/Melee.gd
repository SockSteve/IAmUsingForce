extends PlayerState


func enter(_msg := {}) -> void:
	player.attack_timer = Timer.new()
	player.add_child(player.attack_timer)
	player.attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	if _msg.has("do_air_up_attack"):
		pass
	if _msg.has("do_air_down_attack"):
		pass

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not player.is_attacking:
		attack()
	pass

func attack():
	player.is_attacking = true
	var advance_distance = 1.0  # Adjust as needed
	var advance_direction = -player.global_transform.basis.z.normalized()  # Forward direction, -z is forward
	
	match player.combo_step:
		0:
			#play_attack_animation("attack_1")
			#move_character(advance_direction, advance_distance)
			#combo_step += 1
			pass
		1:
			#play_attack_animation("attack_2")
			#move_character(advance_direction, advance_distance)
			#combo_step += 1
			pass
		2:
			#play_attack_animation("attack_3")
			#move_character(advance_direction, advance_distance)
			#combo_step = 0  # Reset combo after third attack
			pass
	
	player.attack_timer.start(0.5)  # Adjust the duration for how long the combo window is open

func _on_attack_timer_timeout():
	# If the timer runs out, reset combo
	player.combo_step = 0
	player.is_attacking = false

func play_attack_animation(animation_name: String):
	$AnimationPlayer.play(animation_name)

func move_character(direction: Vector3, distance: float):
	var motion = direction * distance
	player.velocity = motion
	player.move_and_slide()

	# Depending on your setup, you may want to adjust the parameters of move_and_slide
	# For example, you might want to use 'stop_on_slope', 'max_slides',
	# 'floor_max_angle', and other parameters to refine the character's movement
