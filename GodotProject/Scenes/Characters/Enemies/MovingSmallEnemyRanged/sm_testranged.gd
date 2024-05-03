extends CharacterBody3D

const SPEED = 5.0
const ACCEL = 12.0
const JUMP_VELOCITY = 4.5

@onready var nav: NavigationAgent3D = $NavigationAgent3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_target: Vector3 = Vector3.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var direction: Vector3 = Vector3()
	
	HelperLibrary.smooth_3d_rotate_towards_Vector(self, current_target, 10.0, delta)
	nav.target_position = current_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction*SPEED, ACCEL*delta)
	
	move_and_slide()

func move_to_random_point():
	pass

func generate_random_vector()->Vector3:
	randomize()
	var one = randf_range(0,5)
	var two = randf_range(0,5)
	var three = randf_range(0,5)
	
	var vector: Vector3 = Vector3(one, two, three)
	return vector
