extends Node3D
class_name Inventory

@onready var gun = preload("res://Scenes/Characters/Player/Weapons/RangedWeapons/Gun/Gun.tscn")
@onready var cutter = preload("res://Scenes/Characters/Player/Weapons/MeleeWeapons/Cutter/Cutter.tscn")

@onready var weapon_node = $Weapons
@onready var gadget_node = $Gadgets

func _ready():
	load_inventory()


func load_inventory():
	#load inventory from save file
	pass

func parameterize_weapon():
	#initialize weapon with xp
	pass

func has_weapon(weapon_name: String):
	if weapon_node.find_child(weapon_name,false,true) != null:
		return true
	return false

func has_gadget(gadget_name: String):
	if gadget_node.find_child(gadget_name,false,true) != null:
		return true
	return false

func get_weapon(weapon_name: String):
	weapon_node.find_child(weapon_name,false,true)

func get_gadget(gadget_name: String):
	gadget_node.find_child(gadget_name,false,true)

func add_weapon(weapon:Node):
	weapon_node.add_child(weapon)
	
func add_gadget(gadget:Node):
	gadget_node.add_child(gadget)

