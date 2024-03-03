extends Node3D

@onready var right_hand_bone_attachement = $"../CharacterSkin".find_child("Hand")
@export var default_weapon_in_hand: PackedScene

func _ready():
	add_weapon_to_hand()

func add_weapon_to_hand():
	right_hand_bone_attachement.add_child(default_weapon_in_hand.instantiate())
	
func change_weapon_in_hand(weapon_inst):
	right_hand_bone_attachement.get_child(0).queue_free()
	right_hand_bone_attachement.add_child(weapon_inst)
