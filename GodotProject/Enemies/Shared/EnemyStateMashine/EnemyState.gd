class_name EnemyState
extends Node

var enemy: Enemy = null
var state_machine: EnemyStateMachine = null

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func on_player_detected(player: Node3D) -> void:
	pass

func on_player_lost(player: Node3D) -> void:
	pass

func on_target_changed(player: Node3D) -> void:
	pass

func on_enemy_staggered() -> void:
	# Default behavior is to do nothing special on stagger
	pass

func resume_from_stagger() -> void:
	# Default behavior is to resume the state's animation
	if enemy:
		match self.name:
			"Idle", "PatrolIdle":
				enemy.play_animation("idle")
			"Roam", "Patrol", "Chase", "ReturnToOrigin":
				enemy.play_animation("walk")
			"Attack":
				# Just let the attack state handle it
				pass
			_:
				enemy.play_animation("idle")

func on_enemy_death() -> void:
	# Default behavior is to do nothing on death
	pass
