class_name Enemy extends CharacterBody3D

@export var hp_component: Hp

@export var animation_player: AnimationPlayer 

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if not hp_component:
		return
	hp_component.death.connect(die)

# Function to handle death.
func die() -> void:
	set_physics_process(false)
	if not animation_player:
		queue_free()
		return
	
	if not animation_player.has_animation("death"):
		queue_free()
		return
	
	print('here')
	animation_player.play("death")
	await  animation_player.animation_finished
	queue_free() # Remove this enemy from the scene.
