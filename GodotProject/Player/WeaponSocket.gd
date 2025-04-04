extends Node3D

func _physics_process(delta: float) -> void:
	if not get_child_count() > 0:
		return
	get_child(0).global_position = global_position
