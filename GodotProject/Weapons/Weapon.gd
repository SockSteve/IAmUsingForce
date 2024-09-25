extends Node3D
class_name Weapon

signal attack_signal

@export_category("Weapon")

@export_group("Basics")
@export var _name : String = ""
@export var upgrade_name: String = ""
@export var _attributes : Dictionary = {}
@export var icon : Texture2D
@export var base_weapon_mesh: Mesh = null
@export var upgraded_weapon_mesh: Mesh = null
@export_group("Shop")
@export var shop_price: int = 0
@export var upgrade_shop_price: int = 0
@export var bullet_price: int = 0
@export_group("Shop Flags")
@export_subgroup("Game")
@export var game_progression_flag: Globals.game_progression_flag_enum
@export_subgroup("Special") 
@export var special_flag : Globals.special_flag_enum
@export_group("Combat")
@export var damage: int = 1
@export var knockback := 0.0
@export var stagger := 0.0
@export var current_ammunition: int = 1
@export var max_ammunition: int = 1
@export var current_lvl: int = 1
@export var max_lvl: = 7
@export var current_experience: int = 0
@export var bullet : PackedScene = null

@export_subgroup("Melee")
@export var max_combo_step: int = 1

@export_group("Level Specifics")
@export var max_experience_per_lvl : Dictionary ={}		#dictionary with all xp values
@export var damage_per_lvl : Dictionary = {}			#dictionary with all dmg values

func init(id, base_name, attributes):
	_name = base_name
	_attributes = attributes

func _ready():
	if name == "":
		_name = self.get_name()

func lvl_up():
	current_lvl += 1
	current_experience = 0
	damage = damage_per_lvl.get(current_lvl, 1)

func gain_experience():
	pass
