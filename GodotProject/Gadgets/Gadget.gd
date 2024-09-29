extends Node3D
class_name Gadget


@export var gadget_stats: GadgetStats
@export var _owner: Player

func get_stats():
	return gadget_stats
