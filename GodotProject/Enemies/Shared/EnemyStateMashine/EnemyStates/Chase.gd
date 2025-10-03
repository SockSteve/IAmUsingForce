class_name ChaseState
extends EnemyState

func enter() -> void:
	enemy.should_stop_movement = false
	enemy.play_animation("walk")

func physics_update(delta: float) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")
		return
	
	var distance_to_target = enemy.global_position.distance_to(enemy.current_target.global_position)
	
	# Check if we can attack based on AI config (only if we can see the target)
	if enemy.can_see_target:
		if distance_to_target <= enemy.ai_config.attack_melee_range and enemy.can_use_melee_attack():
			state_machine.change_state("MeleeAttack")
			return
		elif distance_to_target <= enemy.ai_config.attack_ranged_range and enemy.can_use_ranged_attack():
			state_machine.change_state("RangedAttack")
			return
	
	# Move toward target even if we can't see them (pursuit behavior)
	# This allows the enemy to chase around corners and obstacles
	enemy.move_to_position(enemy.current_target.global_position, delta)

func on_player_lost(player: Node3D) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")
