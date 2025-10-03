class_name EnemyState
extends Node

var enemy: Enemy
var state_machine: EnemyStateMachine

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
	pass

func resume_from_stagger() -> void:
	pass

func on_enemy_death() -> void:
	pass
