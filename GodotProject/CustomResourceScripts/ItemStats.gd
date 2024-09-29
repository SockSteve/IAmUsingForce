extends Resource
class_name ItemStats

enum Type {WEAPON, AMMO, WEAPON_UPGRADE, INTERACTIVE_GADGET, PASSIVE_GADGET, POWER_UP}

@export var id: StringName
@export var name: String
@export var type: Type
@export_multiline var description: String
@export var icon: Texture
@export var mesh: Mesh
@export var shop_price: int
@export var unlock_flags: Array[Globals.GAME_FLAGS]
