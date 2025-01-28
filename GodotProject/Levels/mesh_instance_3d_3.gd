extends MeshInstance3D

@export var object1: Node3D
@export var object2: Node3D

# Create an ImmediateMesh for dynamic drawing
var immediate_mesh = ImmediateMesh.new()
var material = ShaderMaterial.new()

func _ready():
	# Set the mesh to the ImmediateMesh
	mesh = immediate_mesh
	
	# Load or create your shader
	var shader = preload("res://SpecialFX/DebugFx/debug.gdshader") # Replace with your shader path
	material.shader = shader
	
	# Assign the material to the mesh
	material_override = material

func _process(delta):
	# Clear the mesh and redraw the line every frame
	immediate_mesh.clear_surfaces()
	
	# Start drawing the line
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	# Add vertices for the line
	immediate_mesh.surface_add_vertex(object1.global_transform.origin)
	immediate_mesh.surface_add_vertex(object2.global_transform.origin)
	
	# Finish drawing
	immediate_mesh.surface_end()
