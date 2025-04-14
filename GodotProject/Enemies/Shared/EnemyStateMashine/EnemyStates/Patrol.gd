class_name PatrolState
extends EnemyState

@export var patrol_points_parent: NodePath

var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var position_reached: bool = false

func _ready() -> void:
	# Gather patrol points from parent node
	if not patrol_points_parent.is_empty():
		var parent = get_node_or_null(patrol_points_parent)
		if parent:
			for child in parent.get_children():
				if child is Marker3D:
					patrol_points.append(child.global_position)

func enter() -> void:
	enemy.play_animation("walk")
	position_reached = false

func physics_update(delta: float) -> void:
	if patrol_points.is_empty():
		state_machine.change_state("Idle")
		return
		
	if position_reached:
		state_machine.change_state("PatrolIdle")
		return
	
	var target_position = get_current_patrol_point()
	enemy.move_to_position(target_position, delta)
	
	# Check if we've reached the target position
	if enemy.global_position.distance_to(target_position) < 1.0:
		position_reached = true

func get_current_patrol_point() -> Vector3:
	if patrol_points.is_empty():
		return enemy.origin  # Default to origin if no patrol points
	
	return patrol_points[current_patrol_index]

func get_next_patrol_point() -> Vector3:
	if patrol_points.is_empty():
		return enemy.origin  # Default to origin if no patrol points
	
	current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	return patrol_points[current_patrol_index]

func on_player_detected(player: Node3D) -> void:
	state_machine.change_state("Chase")

func on_target_changed(player: Node3D) -> void:
	state_machine.change_state("Chase")
