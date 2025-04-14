class_name PhaseTransitionState
extends EnemyState

var phase_number: int = 0

func enter() -> void:
	enemy.play_animation("phase_transition")
	
	# Determine which phase based on health
	if enemy.hp_component:
		var health_percent = (enemy.hp_component.current_health / float(enemy.hp_component.max_health)) * 100.0
		if health_percent <= 33.0:
			phase_number = 2  # Final phase
		elif health_percent <= 66.0:
			phase_number = 1  # Middle phase
		else:
			phase_number = 0  # Initial phase

	# Play different effects based on the phase we're entering
	match phase_number:
		0:  # Initial phase
			pass
		1:  # Second phase (after 66% health)
			var particles = enemy.get_node_or_null("PhaseChangeParticles")
			if particles:
				particles.emitting = true
		2:  # Final phase (after 33% health)
			var particles = enemy.get_node_or_null("FinalPhaseParticles")
			if particles:
				particles.emitting = true
			
			# Maybe change the enemy's appearance
			var mesh = enemy.get_node_or_null("MeshInstance3D")
			if mesh and mesh.has_method("set_material_override"):
				mesh.material_override = load("res://materials/enemy_enraged.material")

func update(delta: float) -> void:
	# Wait for phase transition animation to complete
	if not enemy.animation_player or not enemy.animation_player.is_playing():
		# Transition to appropriate state based on phase
		match phase_number:
			0:  # Initial phase
				state_machine.change_state("Idle")
			1:  # Second phase
				state_machine.change_state("Chase")
			2:  # Final phase
				state_machine.change_state("Chase")
