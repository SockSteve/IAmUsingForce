class_name PatrolIdleState
extends EnemyState

var idle_timer: float = 0.0
var idle_duration: float = 0.0

func enter() -> void:
	enemy.play_animation("idle")
	
	# Randomize idle duration
	idle_duration = randf_range(
		enemy.ai_config.min_idle_time,
		enemy.ai_config.max_idle_time
	)
	idle_timer = 0.0

func update(delta: float) -> void:
	idle_timer += delta
	
	if idle_timer >= idle_duration:
		# Move to next patrol point
		var patrol_state = state_machine.states.get("Patrol") as PatrolState
		if patrol_state:
			patrol_state.get_next_patrol_point()
		
		state_machine.change_state("Patrol")

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
