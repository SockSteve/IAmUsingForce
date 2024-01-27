extends Node

func save_scene_to_file(scene: Node, path: String):
	var packed_scene = PackedScene.new()
	if packed_scene.pack(scene):
		var result = ResourceSaver.save(packed_scene, path)
		if result == OK:
			print("Scene saved successfully.")
		else:
			print("Failed to save scene.")
	else:
		print("Failed to pack scene.")
		
func load_scene_from_file(path: String) -> Node:
	var loaded_scene = ResourceLoader.load(path) as PackedScene
	if not loaded_scene:
		print("Failed to load scene.")
		return null
	var instanced_scene = loaded_scene.instance()
	return instanced_scene
