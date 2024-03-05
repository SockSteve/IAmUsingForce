extends Node3D
class_name Weapon

@export var _id : int = -1
@export var _base_name : String = ""
@export var _attributes : Dictionary = {}

@export var icon : Texture2D
@export var shop_price: int = 0
@export var bullet_price: int = 0
@export var upgrade_name: String = ""
@export var damage: int = 1
@export var current_ammunition: int = 1
@export var max_ammunition: int = 1
@export var current_lvl: int = 1
@export var max_lvl: = 7
@export var current_experience: int = 0

@export var knockback := 0.0
@export var stagger := 0.0

@export var bullet : PackedScene = null

@export var max_experience_per_lvl : Dictionary ={}		#dictionary with all xp values
@export var damage_per_lvl : Dictionary = {}			#dictionary with all dmg values

func init(id, base_name, attributes):
	_id = id
	_base_name = base_name
	_attributes = attributes

func lvl_up():
	current_lvl += 1
	current_experience = 0
	damage = damage_per_lvl.get(current_lvl, 1)

func gain_experience():
	pass
