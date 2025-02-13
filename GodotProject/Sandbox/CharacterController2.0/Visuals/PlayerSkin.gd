extends Node3D
class_name PlayerSkin

@onready var model : PlayerRig

@onready var alpha_joints: MeshInstance3D = $Alpha_Joints
@onready var alpha_surface: MeshInstance3D = $Alpha_Surface

func accept_model(_rig : PlayerModel):
	model = _model
	beta_surface.skeleton = _rig.skeleton.get_path()
	beta_joints.skeleton = _rig.skeleton.get_path()
