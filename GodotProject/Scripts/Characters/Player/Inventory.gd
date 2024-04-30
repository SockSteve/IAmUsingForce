extends Node3D
class_name Inventory

var weapons: Dictionary = {} 
var gadgets: Dictionary = {}
var weapon_shortcuts: Dictionary = {}
@onready var gadget_node = $"../PassiveGadgets"

func parameterize_weapon():
	#initialize weapon with xp
	pass

func has_weapon(weapon_name: String):
	return weapons.has(weapon_name)

func has_gadget(gadget_name: String):
	if gadget_node.find_child(gadget_name,false,true) != null:
		return true
	return false

func get_weapon(weapon_name: String):
	return weapons.get(weapon_name)

func get_random_weapon(can_get_same_weapon:bool=true):
	#print(weapons.values())
	return weapons.values().pick_random()

func get_gadget(gadget_name: String):
	return gadget_node.find_child(gadget_name)

func add_weapon(weapon_name,weapon_node):
	weapons[weapon_name] = weapon_node
	
func add_gadget(gadget:Node):
	gadget_node.add_child(gadget)

func save():
	#save inventory to disk
	pass
	
func load():
	#load inventory from disk
	pass
