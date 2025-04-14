class_name ReturnToOriginState
extends EnemyState

var origin_reached: bool = false

func enter() -> void:
	enemy.play_animation("walk")
	origin_reached = false

func physics_update(delta: float) -> void:
	if origin_reached:
		state_machine.change_state("Idle")
		return
	
	enemy.move_to_position(enemy.origin, delta)
	
	# Check if we've reached the origin
	if enemy.global_position.distance_to(enemy.origin) < 1.0:
		origin_reached = true

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
