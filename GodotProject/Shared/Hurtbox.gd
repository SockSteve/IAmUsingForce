class_name Hurtbox
extends Area3D

@export var hp_node: Hp
@export var attraction_point: Marker3D

func take_damage(damage: Damage) -> void:
	if not hp_node:
		push_warning("no hp_component!")
		return
	hp_node.take_damage(damage)

func get_attraction_point()->Marker3D:
	if attraction_point:
		return attraction_point
	push_warning("no attraction point set on hurtbox: ", self, " \n returning global position instead")
	return null
	
