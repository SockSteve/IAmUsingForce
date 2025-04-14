class_name MeleeAttackState
extends EnemyState

var attack_timer: float = 0.0
var attack_playing: bool = false

func enter() -> void:
	attack_timer = enemy.ai_config.melee_cooldown if "melee_cooldown" in enemy.ai_config else enemy.ai_config.attack_cooldown
	attack_playing = false
	
	# Make sure we're looking at the target
	if enemy.current_target:
		enemy.smooth_look_at(enemy.current_target.global_position, 0.1)

func update(delta: float) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")
		return
	
	var distance_to_target = enemy.global_position.distance_to(enemy.current_target.global_position)
	
	# If target moved out of melee range but still in detection range
	if distance_to_target > enemy.ai_config.melee_range if "melee_range" in enemy.ai_config else enemy.ai_config.attack_range:
		# Check if the enemy has ranged attacks
		if "has_ranged_attack" in enemy and enemy.has_ranged_attack:
			state_machine.change_state("RangedAttack")
		else:
			state_machine.change_state("Chase")
		return
	
	# Look at the target
	enemy.smooth_look_at(enemy.current_target.global_position, delta)
	
	# Handle attack cooldown
	attack_timer += delta
	if attack_timer >= (enemy.ai_config.melee_cooldown if "melee_cooldown" in enemy.ai_config else enemy.ai_config.attack_cooldown) and not attack_playing:
		attack_playing = true
		
		# Call melee attack function if available, otherwise use default attack
		if "melee_attack" in enemy and enemy.has_method("melee_attack"):
			enemy.melee_attack()
		else:
			enemy.attack()
		
		# Wait for animation to finish before resetting
		if enemy.animation_player:
			await enemy.animation_player.animation_finished
		else:
			await enemy.get_tree().create_timer(1.0).timeout
			
		attack_timer = 0.0
		attack_playing = false

func on_player_lost(player: Node3D) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")

func on_target_changed(player: Node3D) -> void:
	# Just update the attack target, don't change state
	pass

func resume_from_stagger() -> void:
	enemy.play_animation("idle")  # Usually we want to reset to idle after stagger before attacking again
	
	# Check if target is still in melee range
	if enemy.current_target:
		var distance_to_target = enemy.global_position.distance_to(enemy.current_target.global_position)
		if distance_to_target > enemy.ai_config.melee_range if "melee_range" in enemy.ai_config else enemy.ai_config.attack_range:
			if "has_ranged_attack" in enemy and enemy.has_ranged_attack:
				state_machine.change_state("RangedAttack")
			else:
				state_machine.change_state("Chase")
