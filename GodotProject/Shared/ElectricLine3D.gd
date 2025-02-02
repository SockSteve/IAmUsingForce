extends MeshInstance3D
class_name  ElectricLine3D

@export var object1: Node3D
@export var object2: Node3D

@export var thickness: float = 2

@export var fleeting: bool = true
@export var alive_time: float = .5


# ArrayMesh for the line
var array_mesh = ArrayMesh.new() # 
var material = ShaderMaterial.new()

var up_time: float = 0.0

func _ready():
	# Set the mesh to the ArrayMesh
	mesh = array_mesh
	
	# Load or create your shader
	var shader = preload("res://SpecialFX/ElectricArc/ElectricArcRotated.tres") # Replace with your shader path
	material.shader = shader
	material_override = material

func _process(delta):
	if not object1 or not object2:
		return
	
	if fleeting:
		up_time += delta
		if up_time >= alive_time:
			queue_free()
	
	# Clear the mesh and redraw the line every frame
	array_mesh.clear_surfaces()
	
	# Calculate the direction and perpendicular vector
	var start = to_local(object1.global_position)
	var end = to_local(object2.global_position)
	var direction = (end - start).normalized()
	var perpendicular = direction.cross(Vector3.FORWARD).normalized() * thickness
	
	# Define vertices for the quad strip (double-sided)
	var vertices = PackedVector3Array([
		start - perpendicular,
		start + perpendicular,
		end - perpendicular,
		end + perpendicular
	])
	
	# Define UVs for shaders to work
	var uvs = PackedVector2Array([
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(1, 1)
	])
	
	# Define indices for the quad strip (two primitive triangles)
	var indices = PackedInt32Array([0, 1, 2, 2, 1, 3])
	
	# Create a surface from the vertices and indices
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	# Add the surface to the mesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
