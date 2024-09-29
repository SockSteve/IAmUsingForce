extends ItemStats
class_name WeaponStats

signal weapon_lvl_up(weapon) # called for the lvl up screen
signal ammo_stats_changed(weapon)
signal xp_stats_changed(weapon)

const UPGRADE_LEVEL = 7
const MAX_LEVEL = 14

@export var upgrade_name: String
@export var upgrade_icon: Texture
@export var upgrade_weapon_mesh: Mesh

@export var base_damage: int

@export var upgraded: bool: set = _on_upgraded
@export var current_lvl: int = 1 : set = set_current_lvl
@export var current_xp: int = 0 : set = set_current_xp

@export var current_ammo: int = 50 : set = set_current_ammo
@export var max_ammo: int = 100 : set = set_max_ammo

@export var experience_thresholds: Array[int] = [ #[0] == lvl 1 || [6] == lvl 7
100, 200, 300, 400, 500, 600,
700, 800, 900, 1000, 1100, 1200, 1300 ]

@export var base_damage_per_lvl: Array[int] = [ #[0] == lvl 1 || [6] == lvl 7
100, 200, 300, 400, 500, 600,
700, 800, 900, 1000, 1100, 1200, 1300 ]

@export var modifications_per_level = [ #[0] == lvl 1 || [6] == lvl 7
"", "", "", "", "", "",
"", "", "", "", "", "", "" ]


func _on_upgraded(new_value: bool):
	upgraded = new_value
	name = upgrade_name
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

#if not is_node_ready():
		#await ready
