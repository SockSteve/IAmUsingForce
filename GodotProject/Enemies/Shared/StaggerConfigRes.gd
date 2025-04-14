# Stagger Configuration Resource
# stagger_config.gd

class_name StaggerConfig
extends Resource

enum StaggerCondition {
	NEVER,           # Never stagger regardless of damage
	ALWAYS,          # Always stagger on any damage
	DAMAGE_THRESHOLD, # Stagger when damage exceeds threshold
	HEALTH_PERCENT,   # Stagger when health drops below percentage threshold
	HIT_COUNT,        # Stagger after taking a certain number of hits
	HEALTH_PHASES     # Stagger at specific health percentage phases
}

@export var enabled: bool = true
@export var condition: StaggerCondition = StaggerCondition.ALWAYS
@export var damage_threshold: float = 10.0  # For DAMAGE_THRESHOLD
@export var health_percent_threshold: float = 30.0  # For HEALTH_PERCENT (0-100)
@export var health_phases: Array[float] = [66.0, 33.0]  # For HEALTH_PHASES (0-100)
@export var hit_count_threshold: int = 3  # For HIT_COUNT
@export var stagger_duration: float = 0.5
@export var reset_hit_count_after: float = 5.0  # Reset hit counter after this many seconds
@export var immunity_after_stagger: float = 1.0  # Can't be staggered again for this duration
