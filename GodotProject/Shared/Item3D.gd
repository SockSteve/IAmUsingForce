extends Node3D
class_name Item3D

enum Type {WEAPON, AMMO, WEAPON_UPGRADE, INTERACTIVE_GADGET, PASSIVE_GADGET, POWER_UP}

@export var id: StringName
@export var _name: String
@export var type: Type
@export_multiline var description: String
@export var icon: Texture
@export var mesh: Mesh
@export var shop_price: int
@export var unlock_flags: Array[Globals.GAME_FLAGS]

var owner_ref: Player

func get_id()->StringName:
	return id

func get_custom_name()-> String:
	return _name

func get_type()->Type:
	return type

func get_description()-> String:
	return description

func get_icon()->Texture:
	return icon

func get_mesh()-> Mesh:
	return mesh

func get_shop_price()->int:
	return shop_price

func get_unlock_flags()-> Array[Globals.GAME_FLAGS]:
	return unlock_flags

func get_owner_ref()->Node3D:
	return owner_ref
