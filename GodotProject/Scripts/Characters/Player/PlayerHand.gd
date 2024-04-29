extends Node3D

@onready var right_hand_bone_attachement = %CharacterSkin.find_child("MeleeHand")
@onready var ranged_weapon_marker_3d = %CharacterSkin.find_child("RangedHand")

#function is only called from player script and nowhere else
#@param item_inst: node to be placed into players hand
func add_or_replace_item_to_hand(item_inst: Node):
	if right_hand_bone_attachement.get_child_count() == 0 and ranged_weapon_marker_3d .get_child_count() == 0:
		if item_inst.is_in_group("melee"):
			right_hand_bone_attachement.add_child(item_inst)
			return
		ranged_weapon_marker_3d.add_child(item_inst)
	else:
		change_weapon_in_hand(item_inst)
	
func remove_weapon_from_hand():
	right_hand_bone_attachement.get_child(0).queue_free()

func change_weapon_in_hand(item_inst: Node):
	
	var old_item: Node
	if right_hand_bone_attachement.get_children().size() > 0:
		old_item  = right_hand_bone_attachement.get_child(0)
	else:
		old_item = ranged_weapon_marker_3d.get_child(0)
	old_item.get_parent().remove_child(old_item)
	
	if item_inst.is_in_group("melee"):
		right_hand_bone_attachement.add_child(item_inst)
		return
	ranged_weapon_marker_3d.add_child(item_inst)
	
