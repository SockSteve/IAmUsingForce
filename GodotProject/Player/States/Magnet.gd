extends PlayerState


var gravity_strength: float = 9.8
var rotation_speed: float = 5.0
var ray_length: float = 1.5  # Length of the raycast checking for the ground below

# Assuming you have a RayCast node as a child of your character to detect the surface below.
@onready var shapeCast = player._ground_shapecast

func _ready():
	shapeCast = $RayCast
	shapeCast.length = ray_length
	shapeCast.cast_to = Vector3(0, -ray_length, 0)
	shapeCast.force_raycast_update()  # Ensures shapeCast updates every frame

func adjust_orientation(delta):
	# Assuming the shapeCast points downwards relative to the character
	if shapeCast.is_colliding():
		var hit_normal = shapeCast.get_collision_normal()
		var target_up_direction = -hit_normal
		
		# Smoothly rotate the character to align with the new up direction
		var target_rotation = player.Basis(target_up_direction, Vector3(0, 1, 0))
		player.global_transform.basis = player.global_transform.basis.slerp(target_rotation, rotation_speed * delta)

func _physics_process(delta):
	var velocity = Vector3(0, 0, 0)

	# Apply gravity based on detected surface below
	if shapeCast.is_colliding():
		velocity += gravity_strength * shapeCast.get_collision_normal() * delta

	# Handle jumping
	if Input.is_action_just_pressed("ui_jump"):
		# Jump opposite to detected surface's normal
		if shapeCast.is_colliding():
			velocity -= 2 * gravity_strength * shapeCast.get_collision_normal()

	# Movement and sliding. Use -shapeCast.get_collision_normal() to get 'up' direction
	if shapeCast.is_colliding():
		player.velocity = velocity
		player.up_direction = -shapeCast.get_collision_normal()
		#move_and_slide(velocity, -shapeCast.get_collision_normal())
		player.move_and_slide()
	else:
		# If not on the path, default to regular downward gravity
		player.velocity = velocity
		player.up_direction = Vector3.UP
		#move_and_slide(velocity, Vector3.UP)
		player.move_and_slide()
	
	adjust_orientation(delta)
