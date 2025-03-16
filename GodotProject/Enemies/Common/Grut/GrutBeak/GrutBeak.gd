#@tool
extends Enemy

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var attack_range_ray: RayCast3D = $AttackRangeRay
@onready var hurtbox_detection_area_3d: HurtboxDetectionArea3D = $HurtboxDetectionArea3D

const SPEED = 5.0
const ACCEL = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

var player = null

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if animation_player.current_animation == "attack":
		
		move_and_slide()
		return

	if attack_range_ray.is_colliding():
		velocity.x = 0
		velocity.z = 0
		attack()
		return
	
	var direction: Vector3 = Vector3()
	if player != null:
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
		look_at(player.global_position,Vector3.UP,true)
		#HelperLibrary.smooth_3d_rotate_towards(self, player, 10.0, delta)
		nav.target_position = player.global_position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		direction.y = 0.0
		velocity = velocity.lerp(direction*SPEED, ACCEL*delta)
	
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

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
	
