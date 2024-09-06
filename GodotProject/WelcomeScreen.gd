extends Control

@export var level_scene: PackedScene

func _on_button_pressed():
	get_tree().change_scene_to_packed(level_scene)
