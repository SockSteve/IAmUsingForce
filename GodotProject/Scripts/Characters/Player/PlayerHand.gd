extends Node3D

@onready var right_hand_bone_attachement: BoneAttachment3D = %CharacterSkin.find_child("MeleeHand")
#@onready var ranged_weapon_marker_3d = %CharacterSkin.find_child("RangedHand")

#function is only called from player script and nowhere else
#@param item_inst: node to be placed into players hand
func add_or_replace_item_to_hand(item_inst: Node):
	if right_hand_bone_attachement.get_child_count() == 0:
		right_hand_bone_attachement.add_child(item_inst)
	else:
		change_weapon_in_hand(item_inst)
	
func remove_weapon_from_hand():
	right_hand_bone_attachement.get_child(0).queue_free()

func change_weapon_in_hand(item_inst: Node):
	
	var old_item: Node  = right_hand_bone_attachement.get_child(0)
	#old_item.get_parent().remove_child(old_item)
	right_hand_bone_attachement.remove_child(old_item)
	right_hand_bone_attachement.add_child(item_inst)
