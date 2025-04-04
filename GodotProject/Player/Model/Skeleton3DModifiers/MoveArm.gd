@tool
class_name WeaponGripModifier
extends SkeletonModifier3D

# Bone selection for arm chains
@export_enum(" ") var right_hand_bone: String
@export_enum(" ") var right_forearm_bone: String 
@export_enum(" ") var right_arm_bone: String

@export_enum(" ") var left_hand_bone: String
@export_enum(" ") var left_forearm_bone: String
@export_enum(" ") var left_arm_bone: String

# Target nodes for the hands to follow
@export var right_hand_target: NodePath
@export var left_hand_target: NodePath

# FABRIK settings
@export var iterations: int = 5
@export var distance_threshold: float = 0.01
@export_range(0.0, 1.0) var hand_rotation_weight: float = 1.0
@export var debug_draw: bool = true

# Node references
var _right_target_node: Node3D
var _left_target_node: Node3D
var _debug_mesh: MeshInstance3D

func _validate_property(property: Dictionary) -> void:
	var skeleton = get_skeleton()
	if not skeleton:
		return
		
	if property.name.ends_with("_bone"):
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = skeleton.get_concatenated_bone_names()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Get target node references
	if not right_hand_target.is_empty():
		_right_target_node = get_node_or_null(right_hand_target)
	
	if not left_hand_target.is_empty():
		_left_target_node = get_node_or_null(left_hand_target)
	
	# Setup debug visualization
	if debug_draw:
		_setup_debug_mesh()

func _setup_debug_mesh() -> void:
	_debug_mesh = MeshInstance3D.new()
	_debug_mesh.name = "DebugMesh"
	add_child(_debug_mesh)
	
	var im = ImmediateMesh.new()
	_debug_mesh.mesh = im
	
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0, 1, 0)
	_debug_mesh.material_override = material

func _process_modification() -> void:
	var skeleton = get_skeleton()
	if not skeleton:
		return
	
	# Clear debug mesh
	if debug_draw and _debug_mesh:
		var im = _debug_mesh.mesh as ImmediateMesh
		im.clear_surfaces()
	
	# Process right arm if needed
	if _right_target_node and not right_hand_bone.is_empty():
		_apply_fabrik(
			skeleton,
			[right_arm_bone, right_forearm_bone, right_hand_bone],
			_right_target_node,
			Color(1, 0.5, 0.5)  # Light red color for right arm debug
		)
	
	# Process left arm if needed
	if _left_target_node and not left_hand_bone.is_empty():
		_apply_fabrik(
			skeleton,
			[left_arm_bone, left_forearm_bone, left_hand_bone],
			_left_target_node,
			Color(0.5, 0.5, 1)  # Light blue color for left arm debug
		)

# Core FABRIK implementation for a bone chain
func _apply_fabrik(
	skeleton: Skeleton3D,
	bone_names: Array,
	target: Node3D,
	debug_color: Color = Color(0, 1, 0)
) -> void:
	if bone_names.size() < 2:
		push_error("FABRIK needs at least 2 bones in the chain")
		return
	
	# Step 1: Get bone indices for the chain
	var bone_indices = []
	for bone_name in bone_names:
		var bone_idx = skeleton.find_bone(bone_name)
		if bone_idx < 0:
			push_error("Bone not found: " + bone_name)
			return
		bone_indices.append(bone_idx)
	
	# Step 2: Convert target to skeleton space
	var skeleton_global = skeleton.global_transform
	var target_global = target.global_transform
	
	# Ensure target has a normalized basis
	target_global.basis = target_global.basis.orthonormalized()
	
	var target_in_skeleton = skeleton_global.affine_inverse() * target_global
	
	# Step 3: Get current joint positions in skeleton space
	var joint_positions = []
	
	for idx in bone_indices:
		var global_pose = skeleton.get_bone_global_pose(idx)
		joint_positions.append(global_pose.origin)
	
	# Step 4: Calculate bone lengths
	var bone_lengths = []
	for i in range(joint_positions.size() - 1):
		var length = joint_positions[i].distance_to(joint_positions[i + 1])
		bone_lengths.append(length)
	
	# Store the original base position
	var base_position = joint_positions[0]
	
	# Step 5: Apply FABRIK algorithm
	var target_position = target_in_skeleton.origin
	
	# Check if target is reachable
	var total_length = 0
	for length in bone_lengths:
		total_length += length
	
	var base_to_target_distance = base_position.distance_to(target_position)
	
	if base_to_target_distance > total_length:
		# Target is not reachable - stretch toward target
		var direction = (target_position - base_position).normalized()
		
		# Just position joints along the line to target
		joint_positions[0] = base_position  # Keep the base locked
		
		for i in range(1, joint_positions.size()):
			var bone_idx = i - 1
			var segment_length = bone_lengths[bone_idx]
			joint_positions[i] = joint_positions[i-1] + direction * segment_length
	else:
		# Target is reachable - apply full FABRIK iterations
		for iteration in range(iterations):
			# --- Forward reaching ---
			# Set the end effector (hand) at target
			joint_positions[joint_positions.size() - 1] = target_position
			
			# Work backward from target to base
			for i in range(joint_positions.size() - 2, -1, -1):
				var direction = (joint_positions[i] - joint_positions[i + 1]).normalized()
				joint_positions[i] = joint_positions[i + 1] + direction * bone_lengths[i]
			
			# --- Backward reaching ---
			# Lock the base joint (shoulder) to its original position
			joint_positions[0] = base_position
			
			# Work forward from base to end
			for i in range(0, joint_positions.size() - 1):
				var direction = (joint_positions[i + 1] - joint_positions[i]).normalized()
				joint_positions[i + 1] = joint_positions[i] + direction * bone_lengths[i]
			
			# Check if we're close enough to the target
			var end_effector = joint_positions[joint_positions.size() - 1]
			if end_effector.distance_to(target_position) < distance_threshold:
				break
	
	# Step 6: Apply solved joint positions to the skeleton
	_apply_positions_to_bones(skeleton, bone_indices, joint_positions, target_in_skeleton.basis)
	
	# Step 7: Draw debug lines if enabled
	if debug_draw:
		_draw_debug_chain(skeleton_global, joint_positions, target_global.origin, debug_color)

# Apply joint positions to bones
func _apply_positions_to_bones(
	skeleton: Skeleton3D, 
	bone_indices: Array, 
	joint_positions: Array, 
	target_basis: Basis
) -> void:
	# For each bone in the chain
	for i in range(bone_indices.size()):
		var bone_idx = bone_indices[i]
		
		# Get current bone pose
		var bone_pose = skeleton.get_bone_pose(bone_idx)
		
		# If this is the last bone (hand)
		if i == bone_indices.size() - 1 and hand_rotation_weight > 0:
			# Apply target rotation to hand - ensure normalized bases
			var normalized_bone_basis = bone_pose.basis.orthonormalized()
			var normalized_target_basis = target_basis.orthonormalized()
			bone_pose.basis = normalized_bone_basis.slerp(normalized_target_basis, hand_rotation_weight)
			bone_pose.basis = bone_pose.basis.orthonormalized()  # Ensure result is normalized
		elif i < bone_indices.size() - 1:
			# For other bones, orient them to point to the next joint
			var current_pos = joint_positions[i]
			var next_pos = joint_positions[i + 1]
			
			# Calculate a look-at rotation to next joint
			var forward = (next_pos - current_pos).normalized()
			
			# Choose appropriate up vector
			var up = Vector3(0, 1, 0)
			if abs(forward.dot(up)) > 0.99:
				up = Vector3(1, 0, 0)  # Use X as up if forward is along Y
			
			# Create basis with cross products
			var right = forward.cross(up).normalized()
			up = right.cross(forward).normalized()
			
			var new_basis = Basis(right, up, -forward)
			bone_pose.basis = new_basis.orthonormalized()  # Ensure normalized
		
		# Apply position (except for the first bone which should stay in place)
		if i > 0:
			var parent_idx = skeleton.get_bone_parent(bone_idx)
			if parent_idx >= 0:
				var parent_global = skeleton.get_bone_global_pose(parent_idx)
				var local_pos = parent_global.affine_inverse() * Transform3D(Basis.IDENTITY, joint_positions[i])
				bone_pose.origin = local_pos.origin
		
		# Apply the calculated pose
		skeleton.set_bone_pose(bone_idx, bone_pose)

# Draw debug visualization
func _draw_debug_chain(skeleton_global: Transform3D, joint_positions: Array, target_position: Vector3, color: Color) -> void:
	if not debug_draw or not _debug_mesh:
		return
		
	var im = _debug_mesh.mesh as ImmediateMesh
	
	# Draw bone chain
	for i in range(joint_positions.size() - 1):
		var start_pos = skeleton_global * joint_positions[i]
		var end_pos = skeleton_global * joint_positions[i + 1]
		
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		im.surface_set_color(color)
		im.surface_add_vertex(start_pos)
		im.surface_add_vertex(end_pos)
		im.surface_end()
	
	# Draw line to target
	var end_effector = skeleton_global * joint_positions[joint_positions.size() - 1]
	
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_set_color(Color.GREEN)
	im.surface_add_vertex(end_effector)
	im.surface_add_vertex(target_position)
	im.surface_end()
