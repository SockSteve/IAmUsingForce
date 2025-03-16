extends Area3D
class_name Hitbox


@export var one_shot: bool = false

func _ready() -> void:
	area_entered.connect(set_oneshot)

func set_oneshot(_area: Area3D):
	if one_shot:
		queue_free()
