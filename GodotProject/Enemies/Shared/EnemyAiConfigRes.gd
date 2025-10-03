class_name EnemyAIConfig
extends Resource

enum AttackType { MELEE, RANGED, BOTH }

#enemies will always focus the nearest player
@export_group("movement")
@export var move_speed: float = 3.0
@export var rotation_speed: float = 8.0
@export var acceleration: float = 10.0
@export var roam_radius: float = 5.0
@export var avoid_enemies: bool = true
@export var avoid_radius: float = 2.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export_group("combat")
@export var attack_type: AttackType = AttackType.MELEE
@export_subgroup("awareness")
@export var detection_radius: float = 10.0
@export var attack_melee_range: float = 2.0  # Specific melee range
@export var attack_ranged_range: float = 10.0  # Specific ranged range
@export_subgroup("cooldowns")
@export var attack_cooldown: float = 1.0  # General attack cooldown
@export var melee_cooldown: float = 1.0  # Specific melee cooldown
@export var ranged_cooldown: float = 2.0  # Specific ranged cooldown
