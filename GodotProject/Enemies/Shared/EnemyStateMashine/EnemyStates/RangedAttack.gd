class_name RangedAttackState
extends EnemyState

var attack_timer: float = 0.0
var attack_playing: bool = false
var burst_count: int = 0
var max_burst: int = 1  # Default to 1 shot
var burst_delay: float = 0.0
var current_burst_delay: float = 0.0

func enter() -> void:
	attack_timer = enemy.ai_config.ranged_cooldown if "ranged_cooldown" in enemy.ai_config else enemy.ai_config.attack_cooldown
	attack_playing = false
	enemy.should_stop_movement = false
	burst_count = 0
	
	# Get burst settings if available
	if "max_burst_count" in enemy:
		max_burst = enemy.max_burst_count
	if "burst_delay" in enemy:
		burst_delay = enemy.burst_delay
	
	current_burst_delay = 0.0
	
	# Make sure we're looking at the target
	if enemy.current_target:
		enemy.smooth_look_at(enemy.current_target.global_position, 0.1)

func update(delta: float) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")
		return
	
	var distance_to_target = enemy.global_position.distance_to(enemy.current_target.global_position)
	
	# If target got too close and enemy has melee capabilities
	if "has_melee_attack" in enemy and enemy.has_melee_attack and distance_to_target <= (enemy.ai_config.melee_range if "melee_range" in enemy.ai_config else enemy.ai_config.attack_range):
		state_machine.change_state("MeleeAttack")
		return
	
	# If target moved out of ranged attack range
	if distance_to_target > (enemy.ai_config.ranged_range if "ranged_range" in enemy.ai_config else enemy.ai_config.attack_range):
		state_machine.change_state("Chase")
		return
	
	# Look at the target
	enemy.smooth_look_at(enemy.current_target.global_position, delta)
	
	# Handling burst delay (time between shots in a burst)
	if current_burst_delay > 0:
		current_burst_delay -= delta
		return
	
	# Handle attack cooldown
	attack_timer += delta
	if attack_timer >= (enemy.ai_config.ranged_cooldown if "ranged_cooldown" in enemy.ai_config else enemy.ai_config.attack_cooldown) and not attack_playing:
		if burst_count < max_burst:
			attack_playing = true
			burst_count += 1
			
			# Call ranged attack function if available, otherwise use default attack
			if "ranged_attack" in enemy and enemy.has_method("ranged_attack"):
				enemy.ranged_attack()
			else:
				enemy.attack()
			
			# If this isn't the last shot in burst, set up delay for next shot
			if burst_count < max_burst:
				current_burst_delay = burst_delay
				attack_playing = false
			else:
				# Wait for animation to finish before resetting after last shot
				if enemy.animation_player:
					await enemy.animation_player.animation_finished
				else:
					await enemy.get_tree().create_timer(1.0).timeout
				
				attack_timer = 0.0
				attack_playing = false
				burst_count = 0  # Reset burst count after completing a burst

func on_player_lost(player: Node3D) -> void:
	if not enemy.current_target:
		state_machine.change_state("ReturnToOrigin")

func on_target_changed(player: Node3D) -> void:
	# Just update the attack target, don't change state
	pass

func resume_from_stagger() -> void:
	enemy.play_animation("idle")  # Usually we want to reset to idle after stagger before attacking again
	
	# Check if target is still in range and reposition if needed
	if enemy.current_target:
		var distance_to_target = enemy.global_position.distance_to(enemy.current_target.global_position)
		if distance_to_target <= (enemy.ai_config.melee_range if "melee_range" in enemy.ai_config else enemy.ai_config.attack_range) and "has_melee_attack" in enemy and enemy.has_melee_attack:
			state_machine.change_state("MeleeAttack")
		elif distance_to_target > (enemy.ai_config.ranged_range if "ranged_range" in enemy.ai_config else enemy.ai_config.attack_range):
			state_machine.change_state("Chase")
