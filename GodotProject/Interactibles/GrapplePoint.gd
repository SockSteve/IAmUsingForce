class_name GrapplePoint
extends Node3D

#enum where the player can set the desired action to perform on this grapple point
enum grapple_point_type_enum {PULL, SWING, HOLD}
@export var grapple_point_type: grapple_point_type_enum
@onready var jolt_six_dof_joint: JoltGeneric6DOFJoint3D = $JoltGeneric6DOFJoint3D
@onready var jolt_slider_joint: JoltSliderJoint3D = $JoltSliderJoint3D

## monitoring_range describes the maximum range from which the Grapple Point can be detected.
#@export var monitoring_range:= 10.0
## target_distance is the distance the player gets pulled towards before executing the desired action
@export var target_distance := 5.0

#debug shape to make the sphere where the character swings around visible
func _ready():
	DebugLibrary.create_debug_3d_sphere_mesh(global_position, target_distance)

func get_joint()->JoltJoint3D:
	match grapple_point_type:
		grapple_point_type_enum.PULL:
			return jolt_slider_joint
		grapple_point_type_enum.SWING:
			return jolt_six_dof_joint
		grapple_point_type_enum.HOLD:
			return jolt_six_dof_joint
	push_warning("no joint detected")
	return null

#when player enters area and has GrapplingHook, add this GrapplePoint to the detected grapplePoints
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		var grappling_hook = body.get_inventory().get_gadget("GrapplingHook")
		if grappling_hook != null:
			grappling_hook.add_grapple_point(self)
			grappling_hook.player = body

#when player exits area and has GrapplingHook, remove this GrapplePoint from the detected grapplePoints
func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		var grappling_hook = body.get_inventory().get_gadget("GrapplingHook")
		if grappling_hook != null:
			grappling_hook.remove_grapple_point(self)
			#grappling_hook.player = null