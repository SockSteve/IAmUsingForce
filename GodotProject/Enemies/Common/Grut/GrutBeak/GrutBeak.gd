#@tool
extends Enemy
class_name GrutBeak

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var attack_range_ray: RayCast3D = $AttackRangeRay
@onready var hurtbox_detection_area_3d: HurtboxDetectionArea3D = $HurtboxDetectionArea3D

const SPEED = 5.0
const ACCEL = 10.0
const ROTATION_SPEED = 8.0
# Get the gravity from the project settings to be synced with RigidBody nodes.

var player = null

func _physics_process(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_staggered:
		move_and_slide()  # Apply knockback, but stop movement input
		return  # Skip normal movement

	# Stop moving when attacking
	if animation_player.current_animation == "attack":
		move_and_slide()
		return

	# Attack if in range
	if attack_range_ray.is_colliding():
		velocity.x = 0
		velocity.z = 0
		attack()
		return
	
	var direction: Vector3 = Vector3()
	if player != null:
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
		
		# Get player's position and smooth rotate towards them
		var target_position: Vector3 = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		smooth_look_at(target_position, delta)

		# Pathfinding movement
		nav.target_position = player.global_position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		direction.y = 0.0
		velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
		velocity.y = -16
	else:
		# Idle animation when no player is detected
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func smooth_look_at(target: Vector3, delta: float):
	var direction: Vector3 = (target - global_position).normalized()
	direction.y = 0.0  # Ensure the enemy only rotates on the Y-axis

	# Get current and target rotations as quaternions
	var current_rotation: Quaternion = Quaternion(global_transform.basis)
	var target_rotation: Quaternion = Quaternion(Basis.looking_at(direction,Vector3.UP,true))

	# Interpolate between the current and target rotation
	var new_rotation: Quaternion = current_rotation.slerp(target_rotation, ROTATION_SPEED * delta)

	# Apply the interpolated rotation
	global_transform.basis = Basis(new_rotation)

func attack():
	animation_player.play("attack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"attack":
			animation_player.play("idle")


func _on_hurtbox_detection_area_3d_area_entered(area: Hurtbox) -> void:
	player = hurtbox_detection_area_3d.get_closest_area().get_parent()


func _on_hurtbox_detection_area_3d_area_exited(area: Area3D) -> void:
	player = null
	
