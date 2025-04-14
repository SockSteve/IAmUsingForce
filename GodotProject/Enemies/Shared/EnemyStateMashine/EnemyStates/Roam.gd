class_name RoamState
extends EnemyState

var target_position: Vector3 = Vector3.ZERO
var position_reached: bool = false

func enter() -> void:
	enemy.play_animation("walk")
	
	# Choose random position around origin to move to
	var random_direction = Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	).normalized()
	
	target_position = enemy.origin + random_direction * randf_range(0, enemy.ai_config.roam_radius)
	position_reached = false

func physics_update(delta: float) -> void:
	if position_reached:
		state_machine.change_state("Idle")
		return
	
	enemy.move_to_position(target_position, delta)
	
	# Check if we've reached the target position
	if enemy.global_position.distance_to(target_position) < 1.0:
		position_reached = true

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
