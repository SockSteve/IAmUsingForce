extends Node3D
class_name Weapon

signal attack_signal()

enum Type {MELEE, RANGED}

@export var weapon_type: Type
@export var weapon_stats: WeaponStats
@export var bullet: PackedScene
@export var bullet_spawn: Marker3D
@export var attack_sfx: AudioStreamPlayer3D

@export_group("Combat")
@export var knockback := 0.0
@export var stagger := 0.0

@export_subgroup("Ranged")
@export var _bullet_speed : float = 100.0
@export var _fire_rate : float = 0.25

@export_subgroup("Melee")
@export var _max_combo_step: int = 1

var can_attack: bool = true
var _owner: Player

func get_stats():
	return weapon_stats

func attack() -> void:
	pass
