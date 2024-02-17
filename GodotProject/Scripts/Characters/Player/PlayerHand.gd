extends Node3D

@onready var right_hand_bone_attachement = $"../CharacterSkin".find_child("Hand")
# Called when the node enters the scene tree for the first time.

func _ready():
	add_weapon_to_hand()

func add_weapon_to_hand():
	var sword = preload("res://Scenes/Characters/Player/Weapons/MeleeWeapons/Cutter/Cutter.tscn").instantiate()
	right_hand_bone_attachement.add_child(sword)
	
