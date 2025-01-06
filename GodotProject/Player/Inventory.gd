extends Node3D
class_name Inventory

## This class contains all objects the player obtains like money, weapons or Gadgets.
## If any other class needs something from this class it is called from the player
## over the function get_inventory() and from there the class can access the inventory.

signal money_amount_changed(amount: int) ## is emitted when the player receives od spends money.
signal quick_select_panel_changed(index: int) ## is emitted when the qick select panel changes. At the moment there are only 2 panels: panel 1 and 2. Which panel is currently active is expressed through the variable 'current_quick_select_panel' 

@export_range(0,1000000000) var money: int = 10000

var weapons: Dictionary = {} ## key = weapon_name: String | value= weapon_instance_ref: Node
var gadgets: Dictionary = {} ## key = gadget_name: String | value= gadget_instance_ref: Node

## key = shortcut_panel_number: int | 
## value= Dictionary -> {key = index: int | value = weapon_name: String}
var weapon_quick_select: Dictionary = {} 
var current_quick_select_panel: int = 0 ## represense the current active shortcut panel. At the moment we have 2 quick_select panels the player can switch between.

enum quick_select_dir {LEFT_1= 0, LEFT_2= 1, UP_1= 2, UP_2= 3, RIGHT_1= 4, RIGHT_2= 5, DOWN_1= 6, DOWN_2= 7, NONE}
## one value must alway be the melee weapon, the other a ranged weapon
var current_quick_selected = [quick_select_dir.NONE,quick_select_dir.NONE]
## some gadgets like the grinding boots need to be constantly loaded into the scenetree in order to work. These are instanced as child nodes of this node.
@onready var passive_gadgets = $"../CharacterRotationRoot/PassiveGadgets"

func get_money()-> int:
	return money

func add_money(amount)->void:
	money += amount
	money_amount_changed.emit(money)

func remove_money(amount)->void:
	money -= amount
	money_amount_changed.emit(money)

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

func get_random_weapon(_can_get_same_weapon:bool=true)->Node:
	#print(weapons.values())
	return weapons.values().pick_random()

func get_weapons_array_from_quick_select_dir(dir: StringName):
	match dir:
		"up":
			set_current_quick_selected(quick_select_dir.UP_1,quick_select_dir.UP_2)
			return make_weapon_array_from_shortcut_indexes([quick_select_dir.UP_1, quick_select_dir.UP_2])
		"left":
			set_current_quick_selected(quick_select_dir.LEFT_1,quick_select_dir.LEFT_2)
			return make_weapon_array_from_shortcut_indexes([ quick_select_dir.LEFT_1, quick_select_dir.LEFT_2])
		"right":
			set_current_quick_selected(quick_select_dir.RIGHT_1,quick_select_dir.RIGHT_2)
			return make_weapon_array_from_shortcut_indexes([ quick_select_dir.RIGHT_1, quick_select_dir.RIGHT_2])
		"down":
			set_current_quick_selected(quick_select_dir.DOWN_1,quick_select_dir.DOWN_2)
			return make_weapon_array_from_shortcut_indexes([ quick_select_dir.DOWN_1, quick_select_dir.DOWN_2])

#when switch from ranged to melee -> change melee weapon
#when switch from melee to diff melee -> change melee weapon

## only set/change the first value, because that is the current weapon
func set_current_quick_selected(dir_1, dir_2):
	if current_quick_selected[0] == dir_1: 
		current_quick_selected[0] = dir_2
	else:
		current_quick_selected[0] = dir_1

func make_weapon_array_from_shortcut_indexes(indexes: Array[int])-> Array:
	var current_panel: Dictionary = weapon_quick_select.get(current_quick_select_panel)
	var weapon_1 = current_panel.get(indexes[0])
	var weapon_2 = current_panel.get(indexes[1])
	return [weapons.get(weapon_1),weapons.get(weapon_2)]

func populate_quick_select_menu():
	print("Populating shortcut menu...")
	var all_weapons = get_all_weapons()
	var num_weapons = all_weapons.size()
	
	var shuffled_weapons = all_weapons.duplicate()
	shuffled_weapons.shuffle()
	
	var shortcuts_0 = {}
	var shortcuts_1 = {}
	
	var index = 0

	# Populate first panel
	for i in range(8):
		if index < num_weapons:
			shortcuts_0[i] = shuffled_weapons[index].name
			index += 1
		else:
			shortcuts_0[i] = null
	
	shuffled_weapons.shuffle()
	# Populate second panel
	index = 0
	for i in range(8):
		if index < num_weapons:
			shortcuts_1[i] = shuffled_weapons[index].name
			index += 1
		else:
			shortcuts_1[i] = null

	weapon_quick_select[0] = shortcuts_0
	weapon_quick_select[1] = shortcuts_1
	print("Shortcuts populated:", weapon_quick_select)

func change_quick_select_panel():
	if current_quick_select_panel == 1:
		current_quick_select_panel = 0
		emit_signal("quick_select_panel_changed", current_quick_select_panel)
		return
	current_quick_select_panel = 1
	emit_signal("quick_select_panel_changed", current_quick_select_panel)

func get_quick_select_weapon_index(weapon_name: StringName):
	return weapon_quick_select[current_quick_select_panel].find_key(weapon_name)

func get_gadget(gadget_name: StringName)->Node:
	return gadgets.get(gadget_name)

func get_weapon_or_gadget(gadget_or_weapon_name: StringName)-> Node:
	var gadget: Node = gadgets.get(gadget_or_weapon_name)
	if gadget != null: 
		return gadget
	return weapons.get(gadget_or_weapon_name)

func get_all_weapons()->Array:
	return weapons.values()

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
