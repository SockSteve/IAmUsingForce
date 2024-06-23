extends RigidBody3D
class_name PhysicsBody

@export_node_path("Player") var player_path: NodePath

func set_active(active: bool):
	var player: Player = get_node(player_path)
	if active:
		var stored_player_velocity = player.velocity
		global_transform = player.global_transform
		freeze = false
		top_level = true
		linear_velocity = stored_player_velocity
	
	if not active:
		freeze = true
		top_level = false
		player.velocity = linear_velocity
		global_transform = player.global_transform
