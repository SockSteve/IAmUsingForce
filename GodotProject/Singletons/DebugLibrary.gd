extends Node

func _ready():
	#apply_player_highlight()
	pass

func create_debug_3d_box_mesh(position, mesh: Mesh = BoxMesh.new(), size : Vector3 = Vector3(1,1,1)):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh.size = size
	add_child(mesh_instance)
	mesh.global_position = position

func create_debug_3d_sphere_mesh(position:Vector3,size: float = 1):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radius = size * 0.5
	mesh_instance.mesh.height = size
	var material = load("res://Shader/EnergyShield.tres")
	mesh_instance.set_surface_override_material(0,material)
	add_child(mesh_instance)
	mesh_instance.global_position = position

func apply_player_highlight():
	var mesh_instance_3d: MeshInstance3D = get_tree().get_first_node_in_group("debugGroupSkin")
	mesh_instance_3d.mesh.surface_get_material(0).next_pass = load("res://CharacterSkinOutline.tres")
	
func remove_player_highlight():
	var mesh_instance_3d: MeshInstance3D = get_tree().get_first_node_in_group("debugGroupSkin")
	mesh_instance_3d.mesh.surface_get_material(0).next_pass = null
	
