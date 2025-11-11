extends Node
class_name PlayerDebugInjector

## Debug node for injecting test data into the player
## Attach this as a child of Player node for quick testing

@export var auto_inject_on_ready: bool = false
@export_group("Money")
@export var inject_money: bool = false
@export var money_amount: int = 10000

@export_group("Weapons")
@export var inject_weapons: bool = false
@export var weapon_paths: Array[String] = [
	"res://Weapons/MeleeWeapons/Sword.tscn",
	"res://Weapons/RangedWeapons/Pistol.tscn"
]

@export_group("Gadgets")
@export var inject_gadgets: bool = false
@export var gadget_paths: Array[String] = []

var player: Player

func _ready() -> void:
	player = get_parent() as Player
	if player == null:
		printerr("PlayerDebugInjector must be a child of Player node!")
		return

	if auto_inject_on_ready:
		# Wait for player to be fully initialized
		await get_tree().process_frame
		inject_all()

func inject_all() -> void:
	if inject_money:
		inject_money_data()
	if inject_weapons:
		inject_weapon_data()
	if inject_gadgets:
		inject_gadget_data()

	# Populate quick select menu after adding weapons
	if inject_weapons and player.inventory:
		player.inventory.populate_quick_select_menu()
		print("PlayerDebugInjector: Quick select menu populated")

func inject_money_data() -> void:
	if player and player.inventory:
		player.inventory.add_money(money_amount)
		print("PlayerDebugInjector: Injected ", money_amount, " money")

func inject_weapon_data() -> void:
	if not player or not player.inventory:
		printerr("PlayerDebugInjector: Player or inventory not found")
		return

	for weapon_path in weapon_paths:
		if weapon_path.is_empty():
			continue

		if not ResourceLoader.exists(weapon_path):
			printerr("PlayerDebugInjector: Weapon not found at path: ", weapon_path)
			continue

		var weapon_scene = load(weapon_path)
		if weapon_scene == null:
			printerr("PlayerDebugInjector: Failed to load weapon: ", weapon_path)
			continue

		var weapon_instance = weapon_scene.instantiate()
		if weapon_instance == null:
			printerr("PlayerDebugInjector: Failed to instantiate weapon: ", weapon_path)
			continue

		var weapon_id = weapon_instance.get_id() if weapon_instance.has_method("get_id") else StringName(weapon_path.get_file().get_basename())
		player.inventory.add_weapon(weapon_id, weapon_instance)
		print("PlayerDebugInjector: Injected weapon: ", weapon_id)

func inject_gadget_data() -> void:
	if not player or not player.inventory:
		printerr("PlayerDebugInjector: Player or inventory not found")
		return

	for gadget_path in gadget_paths:
		if gadget_path.is_empty():
			continue

		if not ResourceLoader.exists(gadget_path):
			printerr("PlayerDebugInjector: Gadget not found at path: ", gadget_path)
			continue

		var gadget_scene = load(gadget_path)
		if gadget_scene == null:
			printerr("PlayerDebugInjector: Failed to load gadget: ", gadget_path)
			continue

		var gadget_instance = gadget_scene.instantiate()
		if gadget_instance == null:
			printerr("PlayerDebugInjector: Failed to instantiate gadget: ", gadget_path)
			continue

		var gadget_id = gadget_instance.get_id() if gadget_instance.has_method("get_id") else StringName(gadget_path.get_file().get_basename())
		player.inventory.add_gadget(gadget_id, gadget_instance)
		print("PlayerDebugInjector: Injected gadget: ", gadget_id)

# Manual injection methods for calling from console or other scripts
func manual_inject_money(amount: int) -> void:
	if player and player.inventory:
		player.inventory.add_money(amount)
		print("PlayerDebugInjector: Manually injected ", amount, " money")

func manual_inject_weapon(weapon_path: String) -> void:
	if not player or not player.inventory:
		return

	if not ResourceLoader.exists(weapon_path):
		printerr("PlayerDebugInjector: Weapon not found at path: ", weapon_path)
		return

	var weapon_scene = load(weapon_path)
	var weapon_instance = weapon_scene.instantiate()
	var weapon_id = weapon_instance.get_id() if weapon_instance.has_method("get_id") else StringName(weapon_path.get_file().get_basename())
	player.inventory.add_weapon(weapon_id, weapon_instance)
	player.inventory.populate_quick_select_menu()
	print("PlayerDebugInjector: Manually injected weapon: ", weapon_id)
