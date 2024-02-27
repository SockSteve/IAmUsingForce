extends Node

func _ready():
	#apply_player_highlight()
	pass

func create_debug_3d_box(position):
	var mesh : MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	add_child(mesh)
	mesh.global_position = position

func apply_player_highlight():
	var mesh_instance_3d: MeshInstance3D = get_tree().get_first_node_in_group("debugGroupSkin")
	mesh_instance_3d.mesh.surface_get_material(0).next_pass = load("res://CharacterSkinOutline.tres")
	
func remove_player_highlight():
	var mesh_instance_3d: MeshInstance3D = get_tree().get_first_node_in_group("debugGroupSkin")
	mesh_instance_3d.mesh.surface_get_material(0).next_pass = null
	
