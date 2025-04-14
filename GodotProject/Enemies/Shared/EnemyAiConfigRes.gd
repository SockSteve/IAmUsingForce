class_name EnemyAIConfig
extends Resource

enum TargetPriority { FIRST_DETECTED, CLOSEST }

@export var detection_radius: float = 10.0
@export var attack_range: float = 2.0  # General attack range
@export var melee_range: float = 2.0  # Specific melee range
@export var ranged_range: float = 10.0  # Specific ranged range
@export var move_speed: float = 3.0
@export var roam_radius: float = 5.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var target_priority: TargetPriority = TargetPriority.CLOSEST
@export var avoid_enemies: bool = true
@export var avoid_radius: float = 2.0
@export var attack_cooldown: float = 1.0  # General attack cooldown
@export var melee_cooldown: float = 1.0  # Specific melee cooldown
@export var ranged_cooldown: float = 2.0  # Specific ranged cooldown
