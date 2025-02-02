extends Item3D
class_name Weapon

signal attack_signal()
signal weapon_lvl_up(weapon) # called for the lvl up screen
signal ammo_stats_changed(weapon)
signal xp_stats_changed(weapon)

const UPGRADE_LEVEL = 7
const MAX_LEVEL = 14

@export var weapon_type: Type
@export var attack_sfx: AudioStreamPlayer3D
#stats: WeaponStats
@export_group("Stats")
@export var current_lvl: int = 1 : set = set_current_lvl
@export var current_xp: int = 0 : set = set_current_xp
@export_subgroup("lvl steps")
@export var experience_thresholds: Array[int] = [ #[0] == lvl 1 || [6] == lvl 7
100, 200, 300, 400, 500, 600,
700, 800, 900, 1000, 1100, 1200, 1300 ]
@export var base_damage_per_lvl: Array[int] = [ #[0] == lvl 1 || [6] == lvl 7
100, 200, 300, 400, 500, 600,
700, 800, 900, 1000, 1100, 1200, 1300 ]
@export var modifications_per_level = [ #[0] == lvl 1 || [6] == lvl 7
"", "", "", "", "", "",
"", "", "", "", "", "", "" ]

@export_group("Bullet")
@export var current_ammo: int = 50 : set = set_current_ammo
@export var max_ammo: int = 100 : set = set_max_ammo
@export var ammo_shop_price: int = 1
@export var bullet: PackedScene
@export var bullet_spawn: Marker3D

@export_group("Upgrade")
@export var upgrade_name: String
@export var upgrade_icon: Texture
@export var upgrade_weapon_mesh: Mesh
@export var upgraded: bool: set = _on_upgraded

@export_group("Combat")
@export var base_damage: int
@export var knockback := 0.0
@export var stagger := 0.0

@export_subgroup("Ranged")
@export var _bullet_speed : float = 100.0
@export var _fire_rate : float = 0.25

@export_subgroup("Melee")
@export var _max_combo_step: int = 1

var can_attack: bool = true
var _owner: Player

func _on_upgraded(new_value: bool):
	upgraded = new_value
	_name = upgrade_name
	icon = upgrade_icon
	mesh = upgrade_weapon_mesh


func set_current_xp(new_value: int):
	current_xp = new_value
	
	if not upgraded:
		if current_xp >= experience_thresholds[current_lvl - 1] and current_lvl < UPGRADE_LEVEL :
			current_xp -= experience_thresholds[current_lvl - 1]
			current_lvl += 1
			return
	
	if upgraded:
		if current_xp >= experience_thresholds[current_lvl - 1] and current_lvl < MAX_LEVEL :
			current_xp -= experience_thresholds[current_lvl - 1]
			current_lvl += 1
			return
	
	xp_stats_changed.emit(self)
	clamp(current_xp,0,experience_thresholds[current_lvl - 1])


func set_current_lvl(new_value: int):
	current_lvl = new_value
	base_damage = base_damage_per_lvl[current_lvl - 1]
	weapon_lvl_up.emit(self)


func set_max_ammo(new_value):
	max_ammo = new_value
	current_ammo = new_value
	ammo_stats_changed.emit(self)


func set_current_ammo(new_value: int):
	current_ammo = new_value
	ammo_stats_changed.emit(self)

func get_ammo_shop_price()->int:
	return ammo_shop_price

func get_damage() -> int:
	return base_damage_per_lvl[current_lvl - 1]

func get_weapon_name()->String:
	return _name

func get_max_ammo()->int:
	return max_ammo

func get_current_ammo()->int:
	return current_ammo

func add_xp(xp):
	current_xp += xp

func attack() -> void:
	pass
