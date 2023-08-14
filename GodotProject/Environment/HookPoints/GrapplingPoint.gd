class_name GrapplingPoint
extends Node3D

@export var range:= 1100.0
@export var distance := 50.0

func get_grapplingpoint_position():
	return get_child(0).global_transform.origin
