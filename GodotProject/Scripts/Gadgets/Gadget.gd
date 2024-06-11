extends Node3D
class_name Gadget

#const globals = preload("res://Singletons/Globals.gd")

@export_category("Gadget")

@export_group("Basics")
@export var _name : String = ""
@export var _attributes : Dictionary = {}
@export var icon : Texture2D
@export var gadget_mesh: Mesh = null
@export_group("Shop")
@export var shop_price: int = 0
@export_group("Shop Flags")
@export_subgroup("Game")
@export var game_progression_flag: Globals.game_progression_flag_enum
@export_subgroup("Special") 
@export var special_flag : Globals.special_flag_enum
