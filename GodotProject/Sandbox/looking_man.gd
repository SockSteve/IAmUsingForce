extends Node3D

var enemy_position: Vector3 = Vector3.ZERO  # Set this to the enemy's position
var enemy_area: Area3D
@onready var skeleton: Skeleton3D = %GeneralSkeleton
var enemy_detected: bool
@export_node_path("Node3D") var enemy_to_watch
@onready var look_at_modifier_3d: LookAtModifier3D = $YBotWeaponReady/Armature/GeneralSkeleton/LookAtModifier3D

func _ready() -> void:
	await get_tree().process_frame
	var look_at_enemy = get_node(enemy_to_watch)
	look_at_modifier_3d.target_node = look_at_modifier_3d.get_path_to(look_at_enemy)
