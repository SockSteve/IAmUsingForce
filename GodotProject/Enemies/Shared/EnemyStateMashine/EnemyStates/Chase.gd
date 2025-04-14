class_name ChaseState
extends EnemyState

func enter() -> void:
	enemy.play_animation("walk")

func physics_update(delta: float) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")
		return
	
	# First check melee range if the enemy has melee attacks
	if enemy.has_melee_attack and enemy.is_target_in_melee_range():
		state_machine.change_state("MeleeAttack")
		return
	
	# Then check ranged range if the enemy has ranged attacks
	if enemy.has_ranged_attack and enemy.is_target_in_ranged_range():
		state_machine.change_state("RangedAttack")
		return
	
	# If not in attack range, continue chasing
	enemy.move_to_position(enemy.current_target.global_position, delta)

func on_player_lost(player: Node3D) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")

func on_target_changed(player: Node3D) -> void:
	# Just update the chase target, don't change state
	pass
