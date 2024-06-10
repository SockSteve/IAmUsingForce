extends Node3D
class_name Gadget

@export_category("Gadget")

@export_group("Basics")
@export var _name : String = ""
@export var _attributes : Dictionary = {}
@export var icon : Texture2D
@export var gadget_mesh: Mesh = null
@export_group("Shop")
@export var shop_price: int = 0
