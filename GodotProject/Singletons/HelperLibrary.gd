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
func smooth_3d_rotate_towards(rot_source:Node3D, rot_target:Node3D, weight:float, delta: float, up_vector:Vector3=Vector3.UP)->Vector3:
	var direction = rot_source.global_position.direction_to(rot_target.global_position)
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction).get_rotation_quaternion()
	rot_source.transform.basis = Basis(rot_source.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * weight))
	return direction

func smooth_3d_rotate_towards_vector(rot_source:Node3D, rot_target:Vector3, weight:float, delta: float, up_vector:Vector3=Vector3.UP)->Vector3:
	var direction = rot_source.position.direction_to(rot_target)
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction).get_rotation_quaternion()
	rot_source.transform.basis = Basis(rot_source.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * weight))
	return direction
	
func calc_rotation_basis_towards_vector(rot_source:Vector3, rot_target:Vector3, weight:float, delta: float, up_vector:Vector3=Vector3.UP)->Basis:
	var direction = rot_source.direction_to(rot_target)
	var left_axis := up_vector.cross(direction)
	var rotation_basis := Basis(left_axis, up_vector, direction)
	return rotation_basis

func get_random_point_in_3d_area(source: Node3D, inner_radius: float, outer_radius: float)->Vector3:
	var source_position = source.global_position
	# Generate a random angle
	var random_angle = randf_range(0, 2 * PI)
	# Generate a random radius (between 0 and 2 meters)
	var random_radius = randf_range(inner_radius, outer_radius)
	
	# Convert polar coordinates to Cartesian coordinates
	var x = source_position.x + random_radius * cos(random_angle)
	var z = source_position.z + random_radius * sin(random_angle)
	# Set the Y coordinate to the same level as the object (assuming Y is up)
	var y = source_position.y
	return Vector3(x,y,z)
	
func get_random_point_from_vector_in_3d_area(source_pos: Vector3, inner_radius: float, outer_radius: float)->Vector3:
	# Generate a random angle
	var random_angle = randf_range(0, 2 * PI)
	# Generate a random radius (between 0 and 2 meters)
	var random_radius = randf_range(inner_radius, outer_radius)
	
	# Convert polar coordinates to Cartesian coordinates
	var x = source_pos.x + random_radius * cos(random_angle)
	var z = source_pos.z + random_radius * sin(random_angle)
	# Set the Y coordinate to the same level as the object (assuming Y is up)
	var y = source_pos.y
	return Vector3(x,y,z)

func custom_approx_equal(source:Vector3, target:Vector3, approx: float)->bool:
	if source == target: return true
	var x_diff = absf(target.x - source.x)
	var y_diff = absf(target.y - source.y)
	var z_diff = absf(target.z - source.z)
	if Vector3(x_diff,y_diff,z_diff).length() <= approx:
		return true
	return false
	
