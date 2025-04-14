#class_name Enemy 
extends CharacterBody3D

var is_staggered: bool = false  # Flag to prevent movement
@onready var stagger_timer: Timer = Timer.new()  # Timer to reset movement

@export var hp_component: Hp
@export var animation_player: AnimationPlayer 
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if not hp_component:
		return
	hp_component.death.connect(die)
	hp_component.stagger.connect(stagger)

	add_child(stagger_timer)  # Attach the timer to the enemy
	stagger_timer.one_shot = true
	stagger_timer.timeout.connect(_on_stagger_end)

func stagger(impact_point: Vector3, force: float, duration: float = 0.1) -> void:
	if is_staggered:
		return  # Prevent multiple staggers at once

	is_staggered = true
	#var direction = (global_position - impact_point).normalized()  # Direction away from impact
	var knockback_force = impact_point * force  # Apply force
	velocity += knockback_force  # Apply to velocity
	move_and_slide()  # Apply movement

	# Start the stagger timer
	stagger_timer.start(duration)
	
	if not animation_player or not animation_player.has_animation("hit"):
		return
	animation_player.play("hit")

func _on_stagger_end():
	is_staggered = false  # Allow movement again
	animation_player.speed_scale = 1

# Function to handle death.
func die() -> void:
	set_physics_process(false)
	
	if not animation_player or not animation_player.has_animation("death"):
		queue_free()
		return
	
	animation_player.play("death")
	await  animation_player.animation_finished
	queue_free() # Remove this enemy from the scene.
