extends Node3D

@export var character_skin: CharacterSkin

func _ready() -> void:
	if not character_skin:
		printerr("no character assigned to hand")

#function is only called from player script and nowhere else
func add_or_replace_item_to_hand(item_inst: Node):
	if character_skin.right_hand.get_child_count() == 0:
		character_skin.right_hand.add_child(item_inst)
	else:
		change_weapon_in_hand(item_inst)
	
func remove_weapon_from_hand():
	character_skin.right_hand.get_child(0).queue_free()

func change_weapon_in_hand(item_inst: Node):
	var old_item: Node  = character_skin.right_hand.get_child(0)
	character_skin.right_hand.remove_child(old_item)
	character_skin.right_hand.add_child(item_inst)
