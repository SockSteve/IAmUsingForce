extends PlayerState

@onready var ray: RayCast3D = $"../../RayCast3D"

var move_speed = 10.0
var ray_length = 2.0
var distance_from_center = 0.5
var position_offset_y = 0.1
var max_rotation_degrees = 5

func enter(_msg := {}) -> void:
	owner.disableGravity()
	pass

#
func _ready():
	#owner._ground_shapecast = $RayCast
	#owner._ground_shapecast.length = ray_length
	#owner._ground_shapecast.cast_to = Vector3(0, -ray_length, 0)
	#owner._ground_shapecast.force_raycast_update()  # Ensures owner._ground_shapecast updates every frame
	pass




#func adjust_orientation(delta):
#	# Assuming the owner._ground_shapecast points downwards relative to the character
#	if owner._ground_shapecast.is_colliding():
#		var hit_normal = owner._ground_shapecast.get_collision_normal(0)
#		var target_up_direction = -hit_normal
#
#		# Compute right and forward directions based on the up direction
#		var right_direction = Vector3(0, 1, 0).cross(target_up_direction).normalized()
#		var forward_direction = target_up_direction.cross(right_direction)
#
#		# Construct the target basis
#		var target_basis = Basis(right_direction, target_up_direction, forward_direction).orthonormalized()
#
#		# Convert bases to quaternions for slerp
#		var current_quat = owner.global_transform.basis.get_rotation_quaternion()
#		var target_quat = target_basis.get_rotation_quaternion()
#
#		# Perform slerp on quaternions
#		var new_quat = current_quat.slerp(target_quat, rotation_speed * delta)
#
#		# Convert the result back to a Basis and set to global transform
#		owner.global_transform.basis = Basis(new_quat)
#
#
#func physics_update(delta: float) -> void:
#
#	var on_surface = owner._ground_shapecast.is_colliding()
#	var surface_normal = Vector3.UP if not on_surface else owner._ground_shapecast.get_collision_normal(0)
#
#	# Apply gravity 
#	var gravity_velocity = gravity_strength * surface_normal * delta
#	owner.velocity += gravity_velocity
#
#	if Input.is_action_just_pressed("jump") and on_surface:
#		owner.velocity -= jump_strength * surface_normal
#
#	var input_dir = owner._get_camera_oriented_input()
#	if input_dir.length() > 0.1:
#		input_dir = input_dir.normalized()
#
#	var target_velocity = move_speed * input_dir
#	owner.velocity = owner.velocity.lerp(target_velocity, 0.1)
#
#	# For move_and_slide, you need to provide the "up" direction.
#	owner.up_direction = -surface_normal
#	owner.velocity = owner.velocity
#	var movement_result = owner.move_and_slide()
	
	#ray.look_at_from_position(, )
	
#	var velocity = Vector3(0, 0, 0)
#
#	# Get collision info
#	var on_surface = owner._ground_shapecast.is_colliding()
#	var surface_normal = Vector3.UP if !on_surface else owner._ground_shapecast.get_collision_normal(0)
#
#	# Apply gravity based on detected surface
#	#velocity += gravity_strength * surface_normal * delta
#
#	var custom_gravity = Vector3.ZERO
#	custom_gravity += gravity_strength * surface_normal * delta
#
#	# Apply gravity based on detected surface below
#	if owner._ground_shapecast.is_colliding():
#		velocity += gravity_strength * owner._ground_shapecast.get_collision_normal(0) * delta
#
#	# Handle jumping
#	if Input.is_action_just_pressed("jump"):
#		# Jump opposite to detected surface's normal
#		if owner._ground_shapecast.is_colliding():
#			velocity -= 2 * gravity_strength * owner._ground_shapecast.get_collision_normal(0)
#
#	owner._move_direction = owner._get_camera_oriented_input()
#
#	# To not orient quickly to the last input, we save a last strong direction,
#	# this also ensures a good normalized value for the rotation basis.
#	if owner._move_direction.length() > 0.2:
#		owner._last_strong_direction = owner._move_direction.normalized()
#
#	owner._orient_character_to_direction(owner._last_strong_direction, delta)
#
#	# We separate out the y velocity to not interpolate on the gravity
#	var y_velocity = owner.velocity.y
#	owner.velocity.y = 0.0
#	owner.velocity = owner.velocity.lerp(owner._move_direction * owner.move_speed, owner.acceleration * delta)
#	if owner._move_direction.length() == 0 and owner.velocity.length() < owner.stopping_speed:
#		owner.velocity = Vector3.ZERO
#	owner.velocity.y = y_velocity
#	owner.velocity += gravity_strength * surface_normal * delta
#	owner.move_and_slide()
#
#	# Movement and sliding. Use -owner._ground_shapecast.get_collision_normal() to get 'up' direction
#	if owner._ground_shapecast.is_colliding():
#		owner.velocity = velocity
#		owner.up_direction = -owner._ground_shapecast.get_collision_normal(0)
#		owner.velocity += gravity_strength * surface_normal * delta
#		#move_and_slide(velocity, -owner._ground_shapecast.get_collision_normal())
#		owner.move_and_slide()
#	else:
#		# If not on the path, default to regular downward gravity
#		owner.velocity = velocity
#		owner.up_direction = Vector3.UP
#		owner.velocity += gravity_strength * surface_normal * delta
#		#move_and_slide(velocity, Vector3.UP)
#		owner.move_and_slide()

#	adjust_orientation(delta)

