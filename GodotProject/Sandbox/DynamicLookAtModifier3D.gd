extends LookAtModifier3D

func set_custom_target_node(node: Node3D):
	target_node = node.get_path()
