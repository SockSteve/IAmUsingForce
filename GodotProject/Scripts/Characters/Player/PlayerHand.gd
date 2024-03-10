extends Node3D

@onready var right_hand_bone_attachement = %CharacterSkin.find_child("Hand")

func add_or_replace_item_to_hand(item_inst: Node):
	if right_hand_bone_attachement.get_child_count() == 0:
		right_hand_bone_attachement.add_child(item_inst)
	else:
		change_weapon_in_hand(item_inst)
	
func remove_weapon_from_hand():
	right_hand_bone_attachement.get_child(0).queue_free()

func change_weapon_in_hand(item_inst):
	var old_item  = right_hand_bone_attachement.get_child(0)
	old_item.replace_by(item_inst)
	old_item.queue_free()
