extends Node

""" 
function to smoothly rotates a 3D Object towards a target Object.
this function should be called in _process or _physics_process to pass delta

@param rot_source: 		Source Node that will be rotated
@param rot_target: 	Target Node where the Source node will be rotated towards
@param weight: 			determines how fast the source will be rotated
@param delta: 			given from the function where this function will be called
@param up_vector: 		equals by default Vector3.UP. determines if the Source should
						also be rotated on the y axis, or just spins around the x and z axis   
"""
func smooth_3d_rotate_towards(rot_source:Node3D, rot_target:Node3D, weight:float, delta: float, up_vector:Vector3=Vector3.UP):
	var direction = rot_source.position.direction_to(rot_target.global_position)
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction).get_rotation_quaternion()
	rot_source.transform.basis = Basis(rot_source.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * 10.0))
	return direction
