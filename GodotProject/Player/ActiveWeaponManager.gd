extends Node
class_name ActiveWeaponManager

## Manages the player's active weapons and weapon switching logic
## Separates weapon management from the main Player class

signal weapon_changed(weapon_id: StringName)
signal weapon_equipped(weapon: Weapon)

@export var character_skin: CharacterSkin
@export var inventory: Inventory

# Weapon attachment points (accessed from CharacterSkin)
var right_hand_socket: Node3D
var left_hand_socket: Node3D
var back_socket: Node3D
@export_group("Default Weapons")
@export_file("*.tscn") var default_melee_weapon_path: String = "res://Weapons/MeleeWeapons/Cutter/CutterWeapon.tscn"
@export_file("*.tscn") var default_ranged_weapon_path: String = "res://Weapons/RangedWeapons/Gun/GunWeapon.tscn"

# Current active weapons
var current_melee_weapon: Weapon
var current_ranged_weapon: Weapon
var currently_held_weapon_or_gadget: Item3D

# Weapon switching state
var putting_ranged_weapon_in_hand_enabled: bool = true
var stored_weapon_on_gadget_use: Item3D

func _ready() -> void:
	print("ActiveWeaponManager _ready() started")
	# Note: character_skin and inventory should be set by Player before initialize_from_loadout is called
	print("ActiveWeaponManager _ready() completed")

## Put a weapon or gadget in the player's hand
func equip_item(item: Item3D) -> void:
	if not item:
		printerr("ActiveWeaponManager: equip_item called with null item!")
		return

	print("ActiveWeaponManager: Equipping item: ", item.get_id())

	if item is Weapon:
		_assign_weapon_slots(item)

	_place_in_hand(item)
	currently_held_weapon_or_gadget = item

	if item is Weapon:
		weapon_equipped.emit(item)
		print("ActiveWeaponManager: Weapon equipped signal emitted")

## Switch to a specific weapon by ID
func switch_to_weapon(weapon_id: StringName) -> void:
	var weapon = inventory.get_weapon_or_gadget(weapon_id)
	if weapon:
		equip_item(weapon)
		weapon_changed.emit(weapon_id)

## Switch between melee and ranged weapons
func switch_to_melee_weapon() -> void:
	if current_melee_weapon and currently_held_weapon_or_gadget != current_melee_weapon:
		equip_item(current_melee_weapon)

func switch_to_ranged_weapon() -> void:
	if current_ranged_weapon and currently_held_weapon_or_gadget != current_ranged_weapon:
		equip_item(current_ranged_weapon)

## Handle quick select weapon switching
func handle_quick_select(direction: String) -> void:
	if not inventory:
		return
		
	var shortcut_array: Array = inventory.get_weapons_array_from_quick_select_dir(direction)
	if shortcut_array.size() == 0:
		printerr("Error: shortcut_array is empty for direction:", direction)
		return

	var target_weapon: Item3D = null
	
	# Cycle between weapons in the shortcut
	if currently_held_weapon_or_gadget == shortcut_array[0] and shortcut_array[1] != null:
		target_weapon = shortcut_array[1]
	elif shortcut_array[0] != null:
		target_weapon = shortcut_array[0]
	else:
		printerr("Error: No valid weapon in shortcut_array for direction:", direction)
		return

	equip_item(target_weapon)
	weapon_changed.emit(target_weapon.get_id())

## Store current weapon when using gadgets
func store_weapon_for_gadget_use() -> void:
	stored_weapon_on_gadget_use = currently_held_weapon_or_gadget

## Restore weapon after gadget use
func restore_weapon_after_gadget_use() -> void:
	if stored_weapon_on_gadget_use:
		equip_item(stored_weapon_on_gadget_use)
		stored_weapon_on_gadget_use = null

## Initialize weapons from starting loadout
func initialize_from_loadout(starting_loadout: PackedStringArray) -> void:
	print("ActiveWeaponManager: Initializing from loadout. Loadout size: ", starting_loadout.size())

	# Verify and setup weapon sockets
	if not character_skin:
		printerr("ActiveWeaponManager: CharacterSkin not set! Cannot initialize weapons.")
		return

	right_hand_socket = character_skin.right_hand
	left_hand_socket = character_skin.left_hand
	back_socket = character_skin.back

	if not right_hand_socket:
		printerr("ActiveWeaponManager: RightWeaponSocket not found in CharacterSkin!")
		return

	print("ActiveWeaponManager: Found weapon sockets - Right: ", right_hand_socket.name if right_hand_socket else "null")

	# Load weapons from starting loadout
	for weapon_path in starting_loadout:
		if weapon_path.is_empty():
			continue
		print("ActiveWeaponManager: Loading weapon from path: ", weapon_path)
		var weapon_scene = load(weapon_path).instantiate()

		# Set first weapon as currently held
		if currently_held_weapon_or_gadget == null:
			currently_held_weapon_or_gadget = weapon_scene
			print("ActiveWeaponManager: Set ", weapon_scene.get_id(), " as currently held")

		# Assign to appropriate slots
		if current_melee_weapon == null and weapon_scene.is_in_group("melee"):
			current_melee_weapon = weapon_scene
			weapon_scene.owner_ref = get_parent() # Set player as owner
			print("ActiveWeaponManager: Assigned ", weapon_scene.get_id(), " as melee weapon")
		if current_ranged_weapon == null and weapon_scene.is_in_group("ranged"):
			current_ranged_weapon = weapon_scene
			weapon_scene.owner_ref = get_parent() # Set player as owner
			print("ActiveWeaponManager: Assigned ", weapon_scene.get_id(), " as ranged weapon")

		# Add to inventory
		if inventory:
			inventory.add_weapon(weapon_scene.get_id(), weapon_scene)
			print("ActiveWeaponManager: Added ", weapon_scene.get_id(), " to inventory")

	# Ensure default weapons are loaded if none were assigned
	_ensure_default_weapons()

## Get current weapon for attack purposes
func get_current_weapon() -> Weapon:
	if currently_held_weapon_or_gadget is Weapon:
		return currently_held_weapon_or_gadget as Weapon
	return null

## Get current melee weapon
func get_melee_weapon() -> Weapon:
	return current_melee_weapon

## Get current ranged weapon  
func get_ranged_weapon() -> Weapon:
	return current_ranged_weapon

## Check if ranged weapon switching is enabled
func can_switch_to_ranged() -> bool:
	return putting_ranged_weapon_in_hand_enabled

## Enable/disable ranged weapon switching
func set_ranged_switching_enabled(enabled: bool) -> void:
	putting_ranged_weapon_in_hand_enabled = enabled

# Private methods
func _assign_weapon_slots(weapon: Weapon) -> void:
	if weapon.is_in_group("melee"):
		current_melee_weapon = weapon
		weapon.owner_ref = get_parent() # Set player as owner
	if weapon.is_in_group("ranged"):
		current_ranged_weapon = weapon
		weapon.owner_ref = get_parent() # Set player as owner

func _place_in_hand(item: Item3D) -> void:
	if not right_hand_socket:
		printerr("ActiveWeaponManager: Cannot place item in hand - right_hand_socket is null!")
		return

	print("ActiveWeaponManager: Placing ", item.get_id(), " in right hand socket")

	# Remove current item from hand
	if right_hand_socket.get_child_count() > 0:
		var old_item = right_hand_socket.get_child(0)
		right_hand_socket.remove_child(old_item)
		print("ActiveWeaponManager: Removed old item from hand")

	# Add new item to hand socket
	right_hand_socket.add_child(item)
	# Reset item's transform to align with socket
	item.transform = Transform3D.IDENTITY
	print("ActiveWeaponManager: Added ", item.get_id(), " to right hand socket. Children count: ", right_hand_socket.get_child_count())

	# Update character skin animation
	if character_skin:
		print("ActiveWeaponManager: Notifying CharacterSkin of weapon change")
		character_skin.change_weapon(item.get_id(), item.get_groups())
	else:
		printerr("ActiveWeaponManager: CharacterSkin is null, cannot update animation!")

func _ensure_default_weapons() -> void:
	print("ActiveWeaponManager: Ensuring default weapons...")
	print("  Current melee: ", current_melee_weapon.get_id() if current_melee_weapon else "null")
	print("  Current ranged: ", current_ranged_weapon.get_id() if current_ranged_weapon else "null")
	print("  Currently held: ", currently_held_weapon_or_gadget.get_id() if currently_held_weapon_or_gadget else "null")

	var weapon_to_equip: Weapon = null

	# Load default melee weapon if none exists
	if current_melee_weapon == null and not default_melee_weapon_path.is_empty():
		if ResourceLoader.exists(default_melee_weapon_path):
			var melee_weapon = load(default_melee_weapon_path).instantiate()
			current_melee_weapon = melee_weapon
			melee_weapon.owner_ref = get_parent() # Set player as owner
			if inventory:
				inventory.add_weapon(melee_weapon.get_id(), melee_weapon)
			if currently_held_weapon_or_gadget == null:
				weapon_to_equip = melee_weapon
			print("ActiveWeaponManager: Loaded default melee weapon: ", melee_weapon.get_id())
		else:
			printerr("ActiveWeaponManager: Default melee weapon not found at path: ", default_melee_weapon_path)

	# Load default ranged weapon if none exists
	if current_ranged_weapon == null and not default_ranged_weapon_path.is_empty():
		if ResourceLoader.exists(default_ranged_weapon_path):
			var ranged_weapon = load(default_ranged_weapon_path).instantiate()
			current_ranged_weapon = ranged_weapon
			ranged_weapon.owner_ref = get_parent() # Set player as owner
			if inventory:
				inventory.add_weapon(ranged_weapon.get_id(), ranged_weapon)
			if weapon_to_equip == null and currently_held_weapon_or_gadget == null:
				weapon_to_equip = ranged_weapon
			print("ActiveWeaponManager: Loaded default ranged weapon: ", ranged_weapon.get_id())
		else:
			printerr("ActiveWeaponManager: Default ranged weapon not found at path: ", default_ranged_weapon_path)

	# Equip the first available weapon (this will notify CharacterSkin)
	if weapon_to_equip:
		print("ActiveWeaponManager: Equipping default weapon: ", weapon_to_equip.get_id())
		equip_item(weapon_to_equip)
	elif currently_held_weapon_or_gadget:
		# If we already have a weapon set but not equipped, equip it now
		print("ActiveWeaponManager: Equipping already-set weapon: ", currently_held_weapon_or_gadget.get_id())
		equip_item(currently_held_weapon_or_gadget)
	else:
		printerr("ActiveWeaponManager: No weapon to equip!")

	# Populate quick select menu after ensuring weapons exist
	if inventory and inventory.get_all_weapons().size() > 0:
		inventory.populate_quick_select_menu()
		print("ActiveWeaponManager: Quick select menu populated with ", inventory.get_all_weapons().size(), " weapons")
