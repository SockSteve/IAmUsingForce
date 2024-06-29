extends CharacterBody3D
class_name GunBullet

var linear_velocity = Vector3.ZERO

func _ready():
	# Set the bullet to deactivate after a few seconds to prevent it from traveling indefinitely
	#set_process(false)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	# Move the bullet
	translate(linear_velocity * delta)
	move_and_slide()
	if get_slide_collision_count() > 0:
		queue_free()
