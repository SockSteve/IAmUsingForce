extends Node3D
class_name Inventory

signal money_amount_changed(amount: int)

@export_range(0,1000000000) var money: int = 10000

var weapons: Dictionary = {} #key: String | value: Node
var gadgets: Dictionary = {} #key: String | value: Node
var weapon_shortcuts: Dictionary = {} #key: int | value: Dictionary -> {key: index-int | value: weaponName-String} 
@onready var passive_gadgets = $"../CharacterRotationRoot/PassiveGadgets"

func get_money()-> int:
	return money
	
func add_money(amount)->void:
	money += amount
	emit_signal("money_amount_changed", money)

func remove_money(amount)->void:
	money -= amount
	emit_signal("money_amount_changed", money)

func parameterize_weapon():
	#initialize weapon with xp
	pass

func has_weapon(weapon_name: StringName)->bool:
	return weapons.has(weapon_name)

func has_gadget(gadget_name: StringName)->bool:
	return gadgets.has(gadget_name)

func has_gadget_or_weapon(gadget_or_weapon_name: StringName)->bool:
	return weapons.has(gadget_or_weapon_name) or gadgets.has(gadget_or_weapon_name)

func get_weapon(weapon_name: StringName)->Node:
	return weapons.get(weapon_name)

func get_random_weapon(can_get_same_weapon:bool=true)->Node:
	#print(weapons.values())
	return weapons.values().pick_random()

func get_gadget(gadget_name: StringName)->Node:
	return gadgets.get(gadget_name)

func get_weapon_or_gadget(gadget_or_weapon_name: StringName)-> Node:
	var gadget: Node = gadgets.get(gadget_or_weapon_name)
	if gadget != null: 
		return gadget
	return weapons.get(gadget_or_weapon_name)

func add_weapon_or_gadget(item_name: StringName,item_node: Node)->void:
	if item_node is Gadget:
		add_gadget(item_name,item_node)
	else:
		add_weapon(item_name,item_node)

func add_weapon(weapon_name: StringName,weapon_node: Node)->void:
	weapons[weapon_name] = weapon_node

func add_gadget(gadget_name: StringName,gadget_node: Node)->void:
	gadgets[gadget_name] = gadget_node
	if gadget_node.is_in_group("passive"):
		passive_gadgets.add_child(gadget_node)

func save_inventory():
	#save inventory to disk
	pass
	
func load_inventory():
	#load inventory from disk
	pass
