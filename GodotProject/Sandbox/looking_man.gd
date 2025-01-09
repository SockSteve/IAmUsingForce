extends Node3D

@export var walking: bool = false

var enemy_position: Vector3 = Vector3.ZERO  # Set this to the enemy's position
var enemy_area: Area3D
@onready var skeleton: Skeleton3D = %GeneralSkeleton
var enemy_detected: bool


# Bone names (replace with actual names from your skeleton)
var left_leg = "LeftUpperLeg"
var right_leg = "RightUpperLeg"
var left_arm = "LeftUpperArm"
var right_arm = "RightUpperArm"

var walk_speed = 3.0  # Speed of the walk cycle
var walk_amplitude = 0.5  # How much the limbs move


func _process(delta):
	if not enemy_area:
		return
	enemy_position = enemy_area.global_position
	look_at_enemy()
	#animate_body()


func animate_body():
	# Calculate phase for the walk cycle
	var time = Time.get_ticks_msec() / 1000.0
	var phase = time * walk_speed

	# Animate legs
	var left_leg_rotation = sin(phase) * walk_amplitude
	var right_leg_rotation = sin(phase + PI) * walk_amplitude
	set_bone_rotation(left_leg, Vector3(left_leg_rotation, 0, 0))
	set_bone_rotation(right_leg, Vector3(right_leg_rotation, 0, 0))

	# Animate arms (opposite to legs for balance)
	var left_arm_rotation = sin(phase + PI) * walk_amplitude * 0.5
	var right_arm_rotation = sin(phase) * walk_amplitude * 0.5
	set_bone_rotation(left_arm, Vector3(left_arm_rotation, 0, 0))
	set_bone_rotation(right_arm, Vector3(right_arm_rotation, 0, 0))


func set_bone_rotation(bone_name: String, rotation: Vector3):
	var bone_index = skeleton.find_bone(bone_name)
	if bone_index == -1:
		return

	# Get the current local pose of the bone
	var pose = skeleton.get_bone_pose(bone_index)
	pose.basis = Basis().rotated(Vector3(1, 0, 0), rotation.x) * Basis().rotated(Vector3(0, 1, 0), rotation.y) * Basis().rotated(Vector3(0, 0, 1), rotation.z)
	skeleton.set_bone_pose(bone_index, pose)


func look_at_enemy():
	# Ensure the skeleton and enemy position are valid
	if !skeleton or enemy_position == Vector3.ZERO:
		return

	# Get the index of the head bone
	var head_bone_index = skeleton.find_bone("Head")
	if head_bone_index == -1:
		print("Head bone not found")
		return
	
	
	# "_no_override" to always get real pose of current anim frame without modifications you done
	var headRotation : Transform3D = skeleton.get_bone_global_pose_no_override(head_bone_index)
	# Calculate look at as you want...
	enemy_position = (enemy_position - skeleton.global_transform.origin) / skeleton.global_transform.basis.get_scale()
	headRotation = headRotation.looking_at(enemy_position,Vector3.UP,true) # possibly with some tweaks based on your model
	# Set global pose override to your head bone
	skeleton.set_bone_global_pose_override(head_bone_index, headRotation, 1.0, true)
	
	# Get the current global pose of the head bone (without overrides)
	#var head_transform = skeleton.get_bone_global_pose_no_override(head_bone_index)

	# Adjust the transform to look at the target
	#head_transform = head_transform.looking_at(enemy_position, Vector3.UP, true)

	# Apply the global pose override
	#skeleton.set_bone_global_pose_override(head_bone_index, head_transform, 1.0, true)


func _on_area_3d_area_entered(area: Area3D) -> void:
	enemy_area = area


func _on_area_3d_area_exited(area: Area3D) -> void:
	enemy_area = null
