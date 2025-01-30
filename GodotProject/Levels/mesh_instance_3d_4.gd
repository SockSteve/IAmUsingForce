extends MeshInstance3D

# Reference to the two moving objects
@export var object1: Node3D
@export var object2: Node3D

# Thickness of the line
@export var thickness: float = 5

# Create an ArrayMesh for the line
var array_mesh = ArrayMesh.new()
var material = ShaderMaterial.new()

func _ready():
	# Set the mesh to the ArrayMesh
	mesh = array_mesh
	
	# Load or create your shader
	var shader = preload("res://SpecialFX/ElectricArc/ElectricArcRotated.tres") # Replace with your shader path
	material.shader = shader
	
	# Load the noise texture
	#var noise_texture = preload("res://SpecialFX/ElectricArc/ElectricNoise.tres") # Replace with your noise texture path
	#material.set_shader_parameter("noise_texture", noise_texture)
	material_override = material

func _process(delta):
	# Clear the mesh and redraw the line every frame
	
	array_mesh.clear_surfaces()
	
	# Calculate the direction and perpendicular vector
	var start = object1.global_position
	var end = object2.global_position
	var local_start = to_local(start)
	var local_end = to_local(end)
	position = local_start.lerp(local_end, 0.5)
	#self.global_position = (start + end)/3
	var direction = (end - start).normalized()
	
	var perpendicular = direction.cross(Vector3.FORWARD).normalized() * thickness
	
	# Define vertices for the quad strip (double-sided)
	var vertices = PackedVector3Array([
		start - perpendicular,
		start + perpendicular,
		end - perpendicular,
		end + perpendicular
	])
	
	var uvs = PackedVector2Array([
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(1, 1)
	])
	
	# Define indices for the quad strip
	var indices = PackedInt32Array([0, 1, 2, 2, 1, 3])
	
	# Create a surface from the vertices and indices
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	# Add the surface to the mesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
