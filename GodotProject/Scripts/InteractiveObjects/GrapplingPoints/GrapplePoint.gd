class_name GrapplePoint
extends Node3D
## 
enum grapple_point_type_enum {PULL, SWING, TUG}
@export var grapple_point_type: grapple_point_type_enum
@onready var sdof = $JoltGeneric6DOFJoint3D

## @monitoring_range describes the maximum range from which the Grapple Point can be detected.
@export var monitoring_range:= 10.0
## @target_distance is the distance the player gets pulled towards before executing the desired action
@export var target_distance := 5.0

func _ready():
	DebugLibrary.create_debug_3d_sphere_mesh(global_position, target_distance)

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		var grappling_hook = body.get_gadget("GrapplingHook")
		if grappling_hook != null:
			grappling_hook.add_grapple_point(self)

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		var grappling_hook = body.get_gadget("GrapplingHook")
		if grappling_hook != null:
			grappling_hook.remove_grapple_point(self)